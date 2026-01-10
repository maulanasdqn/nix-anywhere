{ ... }:
{
  nix.enable = false;
  determinate-nix.customSettings = {
    eval-cores = 0;
    download-buffer-size = 134217728; # 128 MiB
    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
  };
}
