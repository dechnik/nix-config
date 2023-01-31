{ lib, writeShellApplication, virt-viewer }: (writeShellApplication {
  name = "spice";
  runtimeInputs = [ virt-viewer ];
  text = builtins.readFile ./spice.sh;
}) // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
