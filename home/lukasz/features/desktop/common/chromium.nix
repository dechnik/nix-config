{
  programs.chromium = {
    enable = true;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} #ublock origin
      {id = "nngceckbapebfimnlniiiahkandclblb";} #bitwarden
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} #dark reader
      # {id = "gfbliohnnapiefjpjlpjnehglfpaknnc";} #surfingkeys
      {id = "dbepggeogbaibhgnhhndojpepiihcmeb";} #vimium
      {id = "naepdomgkenhinolocfifgehidddafch";} #browserpass
    ];
  };
}
