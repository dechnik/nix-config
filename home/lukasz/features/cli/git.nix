{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    userName = "lukasz Dechnik";
    userEmail = "lukasz@dechnik.net";
    extraConfig = {
      credential = {
        UseHttpPath = true;
        helper = "!aws codecommit credential-helper $@";
      };
      feature.manyFiles = true;
      init.defaultBranch = "master";
      url."https://github.com/".insteadOf = "git://github.com/";
    };
    lfs = { enable = true; };
    ignores = [ ".direnv" "result" ];
    signing = {
      signByDefault = true;
      key = "D627C2E908C218A4";
    };
  };
}
