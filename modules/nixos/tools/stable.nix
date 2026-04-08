{
  lib,
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    awscli
    # B
    bat
    # bloodhound
    bluez
    bluez-tools
    # C
    cargo
    chromedriver
    chromium
    chrony
    clang
    cloudlens
    cmake
    crane
    # D
    dalfox
    dbeaver-bin
    dig
    dirb
    dirbuster
    direnv
    dive
    dnsutils
    docker
    # E
    enum4linux-ng
    exploitdb
    # F
    ffuf
    findomain
    flameshot
    fastfetch
    # G
    gcc
    gdb
    git
    go
    gowitness
    # H
    # hoppscotch # doesnt work on m1
    hyprland
    # I
    imhex
    # J
    jadx
    jdk11
    jq
    # K
    k9s
    kitty
    kubectl
    kubescape
    # L
    libgcc
    libimobiledevice
    libxslt
    libreoffice-qt6-fresh
    # M
    metasploit
    magic-wormhole-rs
    # N
    neo4j
    neovim
    nikto
    nmap
    nodejs
    # O
    obsidian
    open-vm-tools
    openvpn
    openssl
    opentofu
    # P
    p7zip
    postman
    # R
    ruby
    rustc
    rgbds
    # S
    samdump2
    sameboy
    scrcpy
    spice-vdagent
    sslscan
    # T
    terraform
    tmux
    toybox
    trivy
    # V
    veracrypt
    vscode-extensions.ms-dotnettools.csdevkit
    vscode-extensions.ms-dotnettools.vscode-dotnet-runtime
    # W
    wafw00f
    wget
    whois
    wifite2
    wpscan
    # winetricks
    # wineWowPackages.stable
    # U
    uv
    # Z
    zsh
    zip

    # python
    (python312.withPackages (ps: [ps.requests]))
    python312
    python312Packages.beautifulsoup4
    python312Packages.dirsearch
    python312Packages.numpy
    python312Packages.pipx
    python312Packages.pandas
    python312Packages.pip
    python312Packages.requests
    python312Packages.tldextract
    python312Packages.urllib3
    python312Packages.wcwidth
        
  ];

}
