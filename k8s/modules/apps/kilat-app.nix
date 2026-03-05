# Kilat App - Kubernetes ingress and frontend deployment
#
# kilat-server runs as a systemd service (port 8082), k8s ingress proxies to it.
# kilat-ui is served via nginx pod using nix-csi to mount static files.
{ lib, pkgs, kilat-app, targetSystem, ... }:
let
  labels = {
    "app.kubernetes.io/name" = "kilat";
    "app.kubernetes.io/managed-by" = "easykubenix";
  };

  # Get store paths from flake packages - these update automatically on rebuild
  # Use unsafeDiscardStringContext to allow evaluation without local build
  # (the actual packages will be built on the target system)
  kilatUiPkg = kilat-app.packages.${targetSystem}.kilat-ui or kilat-app.packages.${targetSystem}.default;

  # Convert to strings without build dependency
  kilatUi = builtins.unsafeDiscardStringContext (toString kilatUiPkg);
in
{
  kubernetes.resources.apps = {
    # Kilat Server Service (selector-less, points to systemd service on host)
    Service.kilat-server = {
      metadata.labels = labels // { "app.kubernetes.io/component" = "api"; };
      spec = {
        # No selector — routes to manually defined Endpoints below
        ports = [{ port = 8082; targetPort = 8082; protocol = "TCP"; name = "http"; }];
      };
    };

    # Endpoints pointing to the host where systemd kilat-server runs
    Endpoints.kilat-server = {
      metadata.labels = labels // { "app.kubernetes.io/component" = "api"; };
      subsets = [{
        addresses = [{ ip = "72.62.125.38"; }];
        ports = [{ port = 8082; protocol = "TCP"; name = "http"; }];
      }];
    };

    # Kilat API Ingress
    Ingress.kilat-api = {
      metadata = {
        labels = labels // { "app.kubernetes.io/component" = "api"; };
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true";
          "nginx.ingress.kubernetes.io/proxy-body-size" = "100m";
          # Rate limiting
          "nginx.ingress.kubernetes.io/limit-rps" = "10";
          "nginx.ingress.kubernetes.io/limit-rpm" = "300";
          "nginx.ingress.kubernetes.io/limit-connections" = "20";
          "nginx.ingress.kubernetes.io/limit-burst-multiplier" = "5";
          # Security headers
          "nginx.ingress.kubernetes.io/configuration-snippet" = ''
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
          '';
        };
      };
      spec = {
        ingressClassName = "nginx";
        tls = [{ hosts = [ "api.kilat.app" ]; secretName = "kilat-api-tls"; }];
        rules = [{
          host = "api.kilat.app";
          http.paths = [{
            path = "/";
            pathType = "Prefix";
            backend.service = { name = "kilat-server"; port.number = 8082; };
          }];
        }];
      };
    };

    # Kilat Frontend Deployment (static files via nginx)
    Deployment.kilat-frontend = {
      metadata.labels = labels // { "app.kubernetes.io/component" = "ui"; };
      spec = {
        replicas = 1;
        selector.matchLabels.app = "kilat-frontend";
        template = {
          metadata.labels = { app = "kilat-frontend"; } // labels;
          spec = {
            containers = [
              {
                name = "nginx";
                image = "nginx:alpine";
                ports = [{ containerPort = 80; name = "http"; }];
                volumeMounts = [
                  { name = "nix"; mountPath = "/nix"; readOnly = true; }
                  { name = "nginx-config"; mountPath = "/etc/nginx/conf.d"; }
                ];
                resources = {
                  requests = { memory = "32Mi"; cpu = "10m"; };
                  limits = { memory = "128Mi"; cpu = "100m"; };
                };
              }
            ];
            volumes = [
              {
                name = "nix";
                csi = {
                  driver = "nix.mount.csi";
                  readOnly = true;
                  volumeAttributes.storePath = "${kilatUi}";
                };
              }
              { name = "nginx-config"; configMap.name = "kilat-frontend-nginx"; }
            ];
          };
        };
      };
    };

    # Nginx config for serving static frontend
    # Uses dynamic store path from flake evaluation
    ConfigMap.kilat-frontend-nginx = {
      metadata.labels = labels // { "app.kubernetes.io/component" = "ui"; };
      data."default.conf" = ''
        server {
          listen 80;
          server_name _;
          root ${kilatUi};
          index index.html;
          location / { try_files $uri $uri/ /index.html; }
          location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
          }
        }
      '';
    };

    # Kilat Frontend Service
    Service.kilat-frontend = {
      metadata.labels = labels // { "app.kubernetes.io/component" = "ui"; };
      spec = {
        selector.app = "kilat-frontend";
        ports = [{ port = 80; targetPort = 80; protocol = "TCP"; name = "http"; }];
      };
    };

    # Kilat Frontend Ingress
    Ingress.kilat-frontend = {
      metadata = {
        labels = labels // { "app.kubernetes.io/component" = "ui"; };
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true";
          # Rate limiting (higher for static frontend)
          "nginx.ingress.kubernetes.io/limit-rps" = "50";
          "nginx.ingress.kubernetes.io/limit-connections" = "30";
          "nginx.ingress.kubernetes.io/limit-burst-multiplier" = "10";
          # Security headers
          "nginx.ingress.kubernetes.io/configuration-snippet" = ''
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
          '';
        };
      };
      spec = {
        ingressClassName = "nginx";
        tls = [{ hosts = [ "kilat.app" ]; secretName = "kilat-frontend-tls"; }];
        rules = [{
          host = "kilat.app";
          http.paths = [{
            path = "/";
            pathType = "Prefix";
            backend.service = { name = "kilat-frontend"; port.number = 80; };
          }];
        }];
      };
    };

    # Storage Ingress (MinIO)
    Ingress.kilat-storage = {
      metadata = {
        labels = labels // { "app.kubernetes.io/component" = "storage"; };
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod";
          "nginx.ingress.kubernetes.io/ssl-redirect" = "true";
          "nginx.ingress.kubernetes.io/proxy-body-size" = "1g";
          # Rate limiting for uploads (stricter)
          "nginx.ingress.kubernetes.io/limit-rps" = "20";
          "nginx.ingress.kubernetes.io/limit-connections" = "10";
          "nginx.ingress.kubernetes.io/limit-burst-multiplier" = "3";
        };
      };
      spec = {
        ingressClassName = "nginx";
        tls = [{ hosts = [ "storage.kilat.app" ]; secretName = "kilat-storage-tls"; }];
        rules = [{
          host = "storage.kilat.app";
          http.paths = [{
            path = "/";
            pathType = "Prefix";
            backend.service = { name = "minio"; port.number = 9000; };
          }];
        }];
      };
    };
  };
}
