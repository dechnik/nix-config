{ pkgs, ... }:
let
  spicemenu = pkgs.writeShellScriptBin "spicemenu" ''
    export HYPRLAND_INSTANCE_SIGNATURE="$(ls /tmp/hypr/ -lt | head -2 | tail -1 | rev | cut -d ' ' -f1 | rev)"
    export WAYLAND_DISPLAY="wayland-1"
    source /var/run/secrets/lukasz-pprofile
    declare -a options=("ant
    ebi
    tola
    olek
    quit")

    choice=$(echo -e "$options[@]" | wofi --dmenu -i -p 'Spice to: ')

    if [ "$choice" == 'quit' ]; then
       echo "Program terminated."
    fi
    if [ "$choice" == 'ant' ]; then
       pass=$(wofiaskpass)
       spiceto -u root@pam -p $pass 105 pve $PVEIP
    fi
    if [ "$choice" == 'ebi' ]; then
       pass=$(wofiaskpass)
       spiceto -u root@pam -p $pass 107 pve $PVEIP
    fi
    if [ "$choice" == 'tola' ]; then
       pass=$(wofiaskpass)
       spiceto -u root@pam -p $pass 101 pve $PVEIP
    fi
    if [ "$choice" == 'olek' ]; then
       pass=$(wofiaskpass)
       spiceto -u root@pam -p $pass 102 pve $PVEIP
    fi
  '';
  wofiaskpass = pkgs.writeShellScriptBin "wofiaskpass" ''
    ${pkgs.wofi}/bin/wofi --dmenu -P -i -p 'Password: '
  '';
in
{
  home.packages = with pkgs; [
    spiceto
    wofiaskpass
    spicemenu
  ];
}
