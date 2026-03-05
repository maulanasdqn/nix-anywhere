{ config, lib, pkgs, nix-csi, ... }:
let
  cfg = config.services.k3s;
in
{
  config = lib.mkIf cfg.enable {
    # nix-csi namespace and CSI driver registration
    environment.etc."rancher/k3s/server/manifests/nix-csi.yaml".text = ''
      # Namespace for nix-csi components
      apiVersion: v1
      kind: Namespace
      metadata:
        name: nix-csi
      ---
      # CSIDriver registration
      apiVersion: storage.k8s.io/v1
      kind: CSIDriver
      metadata:
        name: csi.nix.dev
      spec:
        attachRequired: false
        podInfoOnMount: true
        volumeLifecycleModes:
          - Ephemeral
      ---
      # ServiceAccount for nix-csi-node
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: nix-csi-node
        namespace: nix-csi
      ---
      # ClusterRole for CSI node operations
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        name: nix-csi-node
      rules:
        - apiGroups: [""]
          resources: ["pods"]
          verbs: ["get", "list", "watch"]
        - apiGroups: [""]
          resources: ["events"]
          verbs: ["create", "patch"]
        - apiGroups: [""]
          resources: ["nodes"]
          verbs: ["get"]
      ---
      # ClusterRoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: nix-csi-node
      subjects:
        - kind: ServiceAccount
          name: nix-csi-node
          namespace: nix-csi
      roleRef:
        kind: ClusterRole
        name: nix-csi-node
        apiGroup: rbac.authorization.k8s.io
      ---
      # nix-csi-node DaemonSet
      # Note: This is a simplified version. Full deployment requires nix-csi's
      # easykubenix modules for the complete cache + node setup.
      #
      # For full deployment, run from nix-csi repo:
      #   nix build --file . easykubenix.manifestYAMLFile
      #
      # This minimal config enables the CSI driver for pods that specify
      # pre-built store paths in volumeAttributes.
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        name: nix-csi-node
        namespace: nix-csi
        labels:
          app: nix-csi-node
      spec:
        selector:
          matchLabels:
            app: nix-csi-node
        template:
          metadata:
            labels:
              app: nix-csi-node
          spec:
            serviceAccountName: nix-csi-node
            hostNetwork: true
            hostPID: true
            containers:
              - name: nix-csi
                # Using a placeholder - will be replaced with actual nix-csi image
                # TODO: Build and push nix-csi node image to registry
                image: ghcr.io/lillecarl/nix-csi-node:latest
                imagePullPolicy: Always
                securityContext:
                  privileged: true
                env:
                  - name: NODE_ID
                    valueFrom:
                      fieldRef:
                        fieldPath: spec.nodeName
                  - name: CSI_ENDPOINT
                    value: unix:///csi/csi.sock
                volumeMounts:
                  - name: plugin-dir
                    mountPath: /csi
                  - name: pods-mount-dir
                    mountPath: /var/lib/kubelet/pods
                    mountPropagation: Bidirectional
                  - name: nix-store
                    mountPath: /nix
                    mountPropagation: Bidirectional
                ports:
                  - containerPort: 9808
                    name: healthz
                    protocol: TCP
                livenessProbe:
                  httpGet:
                    path: /healthz
                    port: healthz
                  initialDelaySeconds: 10
                  periodSeconds: 30
              - name: node-driver-registrar
                image: registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.1
                args:
                  - "--csi-address=/csi/csi.sock"
                  - "--kubelet-registration-path=/var/lib/kubelet/plugins/csi.nix.dev/csi.sock"
                volumeMounts:
                  - name: plugin-dir
                    mountPath: /csi
                  - name: registration-dir
                    mountPath: /registration
            volumes:
              - name: plugin-dir
                hostPath:
                  path: /var/lib/kubelet/plugins/csi.nix.dev
                  type: DirectoryOrCreate
              - name: pods-mount-dir
                hostPath:
                  path: /var/lib/kubelet/pods
                  type: Directory
              - name: registration-dir
                hostPath:
                  path: /var/lib/kubelet/plugins_registry
                  type: Directory
              - name: nix-store
                hostPath:
                  path: /nix
                  type: Directory
    '';

    # Ensure /nix is available on the host for CSI mounts
    # k3s nodes need access to the Nix store
    systemd.tmpfiles.rules = [
      "d /nix 0755 root root -"
    ];
  };
}
