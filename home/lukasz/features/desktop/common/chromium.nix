{
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # dark reader
      # {id = "gfbliohnnapiefjpjlpjnehglfpaknnc";} #surfingkeys
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      { id = "naepdomgkenhinolocfifgehidddafch"; } # browserpass
    ];
    commandLineArgs = [
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder"
      "--enable-zero-copy"
      "--disable-gpu-driver-bug-workarounds"
      "--use-gl=egl"
      "--ignore-gpu-blocklist"
    ];
  };
}
