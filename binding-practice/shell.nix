{
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/7cbf6ca1c84dfc917c1a99524e082fb677501844.tar.gz) {}
}:
  with pkgs;
  haskell.lib.buildStackProject {
    name = "haskell-binding-example";
    buildInputs = [haskellPackages.c2hs];
    shellHook = ''
      set -v
      alias stack="\stack --nix"
      set +v
    '';
  }
