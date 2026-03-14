{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.29.0";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
      hash = "sha256-N6pzwJ8EQ2AytMbvGOSG7zHl2Qy6NLGdLCujbnL6QHI=";
    };
    x86_64-darwin = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-apple-darwin.tar.gz";
      hash = "sha256-YApQtj5T7/PIvB+94Ambtwtcd1iLqlBL6F/4y0ljS6Y=";
    };
    x86_64-linux = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-FxUUIt+JKO7OSmYlS5dNanJliCDrAMwYqoh8t3/PnGg=";
    };
    aarch64-linux = {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-Edn9SbaN1tBb6VNDSEIS+cppt8AnCk/dl+XsHkdzqdg=";
    };
  };

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "rtk";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
  };

  sourceRoot = ".";

  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''
    install -Dm755 rtk $out/bin/rtk
  '';

  meta = with lib; {
    description = "CLI proxy that reduces LLM token consumption by 60-90%";
    homepage = "https://github.com/rtk-ai/rtk";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "rtk";
  };
}
