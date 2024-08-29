{ pkgs, ... }:
# cli utilities
{
  home.packages = with pkgs; [
    awscli
    winbox
    # aws-sam-cli
    azure-cli
    # azure-functions-core-tools
    bicep
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
