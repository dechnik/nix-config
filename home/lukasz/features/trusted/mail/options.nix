{ config
, lib
, ...
}:
with lib; {
  options.display-folders = mkOption {
    type = types.listOf types.str;
    default = [ "Inbox" ];
    example = ''[ "Inbox" ]'';
    description = "List of folders *in order* to display for this account";
  };
  options.sig-org = mkOption {
    type = types.str;
    default = "sig";
    example = "sig";
    description = "Signature to use with mu4e config";
  };
}
