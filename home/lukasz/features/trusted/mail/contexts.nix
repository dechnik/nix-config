{
  config,
  lib,
  ...
}:
accounts:
with lib; let
  neomuttAccounts = filter (a: a.neomutt.enable) (attrValues accounts);
  primaryAccount =
    head (filter (a: a.primary) neomuttAccounts ++ neomuttAccounts);
  otherAccounts = filter (a: a != primaryAccount) neomuttAccounts;

  accountConfig = account: let
    accName = "${account.name}";
    accAddr = "${account.address}";
    accSig = "${account.sig-org}";
  in ''
    ,(make-mu4e-context
         :name "${accName}"
         :enter-func (lambda ()
                     (mu4e-message "Entering ${accName} context")
                     (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                     (revert-buffer)))
         :leave-func (lambda ()
                     (mu4e-message "Leaving ${accName} context")
                     (when (string-match-p (buffer-name (current-buffer)) "mu4e-main")
                     (revert-buffer)))
         :match-func
         (lambda (msg)
           (when msg
             (string=
              (mu4e-message-field msg :maildir)
              "/${accName}")))
         :vars '((user-mail-address . "${accAddr}")
                 (mu4e-sent-folder . "/${accName}/Sent")
                 (mu4e-refile-folder . "/${accName}/Archive")
                 (mu4e-drafts-folder . "/${accName}/Drafts")
                 (mu4e-trash-folder . "/${accName}/Trash")
                 (org-msg-greeting-fmt . "\nHi%s,\n\n")
                 (org-msg-signature . "${accSig}")))
  '';
in ''
  (setq
   mu4e-contexts `(
     ${accountConfig primaryAccount}
     ${concatMapStringsSep "" accountConfig otherAccounts}
   ))
''
