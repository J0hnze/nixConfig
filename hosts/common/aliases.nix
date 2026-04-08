{ ... }:

{
  programs.zsh.shellAliases = {

    ll = "ls -lah";
    la = "ls -la";

    rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";

    _clean-up = ''
      sudo nix-collect-garbage -d &&
      sudo nix store gc &&
      sudo journalctl --vacuum-time=7d &&
      sudo rm -rf ~/.cache/thumbnails/* &&
      sudo rm -rf ~/.cache/* &&
      sudo rm -rf /tmp/*
    '';

    _update = ''
      cd /home/johnze/Developer/Projects/nixConfig &&
      nix flake update &&
      sudo nixos-rebuild switch --flake .#$(hostname)
    '';
  };
}