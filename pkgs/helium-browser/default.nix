{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "helium-browser";
  version = "0.12.4.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-OgS8HkLBseFrEhNFJxMwp1bg0gzPdfY1VaySAAp7vq0=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/helium.desktop $out/share/applications/helium.desktop
    install -Dm644 ${appimageContents}/helium.png \
      $out/share/icons/hicolor/256x256/apps/helium.png
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-quiet 'Exec=AppRun' "Exec=$out/bin/${pname}"
  '';

  meta = with lib; {
    description = "Privacy-focused Chromium-based browser by imputnet";
    homepage = "https://helium.computer/";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
