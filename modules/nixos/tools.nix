{lib,config,pkgs, ...}:
#let unstable-pkgs = import <nixos-unstable> { config = { allowUnfree = true; }; };

environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    apktool
    apksigner
    android-tools
    altair
    awscli
    bloodhound
    bluez 
    bluez-tools 
    chromedriver 
    chromium
    chrony
    dalfox
    dbeaver-bin
    dig
    dirb
    dirbuster
    direnv 
    docker
    enum4linux-ng
    ffuf
    #frida-tools
    flameshot
    gcc
    git
    go
    gowitness
    gdb
    hyprland
    jadx    
    jdk11
    jq
    imhex
    kitty
    libgcc
    libimobiledevice
    libxslt
    libreoffice-qt6-fresh    
    neo4j
    neovim
    nikto
    nmap
    nodejs
    obsidian
    open-vm-tools
    openvpn
    openssl
    opentofu
    postman
    ruby
    rgbds
    samdump2
    sameboy
    scrcpy
    spice-vdagent
    terraform
    tmux
    toybox
    veracrypt
    vscode
    vscode-extensions.ms-dotnettools.csdevkit
    vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
    wget
    wifite2
    winetricks
    wineWowPackages.stable
    uv
    zsh

#python
    python313
    python313Packages.pipx
    python313Packages.pandas    
    python313Packages.pip
    python313Packages.numpy
    python313Packages.requests
    python313Packages.wcwidth
#    python3Packages = pkgs.python312Packages;

# #unstable
#     unstable-pkgs.bruno
#     (unstable-pkgs.burpsuite.override { proEdition = true; })    
#     unstable-pkgs.android-studio
#     unstable-pkgs.nuclei
#     unstable-pkgs.platformio
#     unstable-pkgs.postman
#     unstable-pkgs.netexec
  ];