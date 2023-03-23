{ pkgs, ... }: {
  home.packages = with pkgs; [
    kubectl
    yq
  ];
}
