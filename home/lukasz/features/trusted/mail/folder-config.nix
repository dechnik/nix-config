{ config, lib, ... }:
# A function given the contents of config.accounts.email.accounts which renders
# a neomutt configuration snippet which shows the primary account and thence the
# other accounts in alphabetical order, rendering the folders therein...
accounts:
with lib;
let
  neomuttAccounts = filter (a: a.neomutt.enable) (attrValues accounts);
  primaryAccount = head (filter (a: a.primary) neomuttAccounts ++ neomuttAccounts);
  otherAccounts = filter (a: a != primaryAccount) neomuttAccounts;

  accountConfig =
    account:
    let
      baseDir = "${config.xdg.dataHome}/mail/${account.name}";
      folders = account.display-folders;
      folder-parts = folder: splitString "/" folder;
      folder-suffix = folder: last (folder-parts folder);
      folder-prefix = folder: concatStringsSep "" (map (f: "  ") (folder-parts folder));
      folder-name = folder: ''
        "${folder-prefix folder}${folder-suffix folder}" "${baseDir}/${folder}"
      '';
      folder-command = folder: "named-mailboxes ${folder-name folder}";
    in
    ''
      # Configuration for account '${account.name}'

      named-mailboxes "---${account.name}---" "${baseDir}/.null"
      ${concatMapStringsSep "" folder-command folders}
    '';
in
''
  # First we clear all mailboxes
  unmailboxes *

  ${accountConfig primaryAccount}

  ${concatMapStringsSep "\n\n" accountConfig otherAccounts}
''
