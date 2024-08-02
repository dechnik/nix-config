{ pkgs, config, ... }:
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
      user.signing.key = "CE738DF1C1B0BCA2F343FFD0D627C2E908C218A4";
      commit.gpgSign = true;
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";
      diff.lisp.xfuncname = "^(((;;;+ )|\\(|([ \t]+\\(((cl-|el-patch-)?def(un|var|macro|method|custom)|gb/))).*)$";
      diff.org.xfuncname = "^(\\*+ +.*)$";
    };
    lfs.enable = true;
    ignores = [
      ".idea"
      ".direnv"
      "result"
    ];
  };
}
