{ inputs, pkgs, ... }:
# cli utilities
{
  home.packages = with pkgs; [
    awscli2
    winbox
    # aws-sam-cli
    # azure-cli
    # azure-functions-core-tools
    bicep
    terraform
    inputs.azure-dev-cli.packages.${system}.default
  ];
  home.sessionVariables.FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT = 1;
  home.sessionVariables.AZURE_DEV_COLLECT_TELEMETRY = "no";
  home.sessionVariables = {
    AWS_CONFIG_FILE = "$HOME/.config/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "$HOME/.config/aws/credentials";
  };
  home.persistence = {
    "/persist/home/lukasz".directories = [ ".config/aws" ];
  };
}
