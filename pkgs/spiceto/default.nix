{ lib, writeShellApplication, virt-viewer }: (writeShellApplication {
  name = "spiceto";
  runtimeInputs = [ virt-viewer ];
  text = builtins.readFile ./spiceto.sh;
}) // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
