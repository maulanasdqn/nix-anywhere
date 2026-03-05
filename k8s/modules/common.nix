# Common Kubernetes settings for all modules
{ lib, ... }:
{
  # Create the apps namespace (cluster-scoped resource goes under "none")
  kubernetes.resources.none.Namespace.apps = {
    metadata.labels = {
      "app.kubernetes.io/managed-by" = "easykubenix";
    };
  };
}
