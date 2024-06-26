{ pkgs, ... }:
# cli utilities
{
  home.packages = with pkgs; [
    awscli
    # aws-sam-cli
    azure-cli
    # azure-functions-core-tools
    terraform
  ];
  home.sessionVariables.FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT = 1;
  home.sessionVariables = {
    AWS_CONFIG_FILE = "$HOME/.config/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "$HOME/.config/aws/credentials";
  };
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".config/aws" ];
  };
}
