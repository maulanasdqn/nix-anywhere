{
  description = "nix-mount-csi - CSI driver for mounting /nix into Kubernetes pods";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          nix-mount-csi = pkgs.buildGoModule {
            pname = "nix-mount-csi";
            version = "0.1.0";

            src = ./.;

            # Use vendored dependencies
            vendorHash = "sha256-ygdB2/uR9JibTeEslU3rDwUz3Fjye5MFhlSueF6EyUw=";

            subPackages = [ "cmd/nix-mount-csi" ];

            ldflags = [
              "-s" "-w"
              "-X main.version=0.1.0"
            ];

            meta = with pkgs.lib; {
              description = "CSI driver for mounting /nix into Kubernetes pods";
              license = licenses.mit;
            };
          };

          # Container image with nix for flake building
          container = pkgs.dockerTools.buildLayeredImage {
            name = "nix-mount-csi";
            tag = "latest";

            contents = [
              nix-mount-csi
              pkgs.coreutils
              pkgs.util-linux
              pkgs.nix          # For nix build command
              pkgs.git          # For fetching flakes from git
              pkgs.cacert       # For HTTPS
              pkgs.gnutar       # For unpacking sources
              pkgs.gzip
              pkgs.xz
            ];

            config = {
              Entrypoint = [ "${nix-mount-csi}/bin/nix-mount-csi" ];
              Env = [
                "PATH=${nix-mount-csi}/bin:${pkgs.nix}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:${pkgs.util-linux}/bin"
                "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              ];
            };
          };

          # Kubernetes manifests with image reference
          manifests = pkgs.writeText "nix-mount-csi.yaml" ''
            apiVersion: v1
            kind: Namespace
            metadata:
              name: nix-csi
            ---
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
            apiVersion: v1
            kind: ServiceAccount
            metadata:
              name: nix-mount-csi
              namespace: nix-csi
            ---
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
                        - name: HOME
                          value: /root
                      volumeMounts:
                        - name: plugin-dir
                          mountPath: /csi
                        - name: pods-mount-dir
                          mountPath: /var/lib/kubelet/pods
                          mountPropagation: Bidirectional
                        - name: nix-store
                          mountPath: /nix
                          mountPropagation: Bidirectional
                        - name: nix-config
                          mountPath: /etc/nix
                          readOnly: true
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
                    - name: nix-config
                      hostPath:
                        path: /etc/nix
                        type: DirectoryOrCreate
          '';

        in {
          default = nix-mount-csi;
          inherit nix-mount-csi container manifests;
        }
      );
    };
}
