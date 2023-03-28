{ pkgs, ... }:
# cli utilities
{
  home.packages = with pkgs; [
    # awscli
    # aws-sam-cli
    azure-cli
    terraform
  ];
  home.sessionVariables = {
    AWS_CONFIG_FILE = "$HOME/.config/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "$HOME/.config/aws/credentials";
  };
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".config/aws" ];
  };
}
