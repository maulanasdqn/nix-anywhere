{ pkgs ? import <nixpkgs> { } }:

let
  nix-mount-csi = pkgs.buildGoModule {
    pname = "nix-mount-csi";
    version = "0.1.0";

    src = ./.;

    vendorHash = null; # Will be updated after first build

    subPackages = [ "cmd/nix-mount-csi" ];

    meta = with pkgs.lib; {
      description = "CSI driver for mounting /nix into Kubernetes pods";
      homepage = "https://github.com/msdqn/nix-mount-csi";
      license = licenses.mit;
      maintainers = [ ];
    };
  };

  # Container image for the CSI driver
  container = pkgs.dockerTools.buildImage {
    name = "nix-mount-csi";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [
        nix-mount-csi
        pkgs.coreutils
        pkgs.util-linux # For mount utilities
        pkgs.nix        # For nix build capabilities
      ];
      pathsToLink = [ "/bin" ];
    };

    config = {
      Entrypoint = [ "/bin/nix-mount-csi" ];
      Env = [
        "PATH=/bin"
      ];
    };
  };

  # Kubernetes manifests
  manifests = pkgs.writeText "nix-mount-csi.yaml" ''
    # Namespace
    apiVersion: v1
    kind: Namespace
    metadata:
      name: nix-csi
    ---
    # CSI Driver registration
    apiVersion: storage.k8s.io/v1
    kind: CSIDriver
    metadata:
      name: nix.mount.csi
    spec:
      attachRequired: false
      podInfoOnMount: true
      volumeLifecycleModes:
        - Ephemeral
    ---
    # ServiceAccount
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: nix-mount-csi
      namespace: nix-csi
    ---
    # ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: nix-mount-csi
    rules:
      - apiGroups: [""]
        resources: ["pods"]
        verbs: ["get", "list", "watch"]
      - apiGroups: [""]
        resources: ["nodes"]
        verbs: ["get"]
    ---
    # ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: nix-mount-csi
    subjects:
      - kind: ServiceAccount
        name: nix-mount-csi
        namespace: nix-csi
    roleRef:
      kind: ClusterRole
      name: nix-mount-csi
      apiGroup: rbac.authorization.k8s.io
    ---
    # DaemonSet
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: nix-mount-csi
      namespace: nix-csi
    spec:
      selector:
        matchLabels:
          app: nix-mount-csi
      template:
        metadata:
          labels:
            app: nix-mount-csi
        spec:
          serviceAccountName: nix-mount-csi
          hostNetwork: true
          hostPID: true
          containers:
            - name: csi-driver
              image: nix-mount-csi:latest
              imagePullPolicy: Never
              securityContext:
                privileged: true
              args:
                - "--endpoint=unix:///csi/csi.sock"
                - "--nodeid=$(NODE_ID)"
                - "-v=4"
              env:
                - name: NODE_ID
                  valueFrom:
                    fieldRef:
                      fieldPath: spec.nodeName
              volumeMounts:
                - name: plugin-dir
                  mountPath: /csi
                - name: pods-mount-dir
                  mountPath: /var/lib/kubelet/pods
                  mountPropagation: Bidirectional
                - name: nix-store
                  mountPath: /nix
                  mountPropagation: Bidirectional
            - name: node-driver-registrar
              image: registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.1
              args:
                - "--csi-address=/csi/csi.sock"
                - "--kubelet-registration-path=/var/lib/kubelet/plugins/nix.mount.csi/csi.sock"
              volumeMounts:
                - name: plugin-dir
                  mountPath: /csi
                - name: registration-dir
                  mountPath: /registration
          volumes:
            - name: plugin-dir
              hostPath:
                path: /var/lib/kubelet/plugins/nix.mount.csi
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

in {
  inherit nix-mount-csi container manifests;

  # Convenience attribute
  default = nix-mount-csi;
}
