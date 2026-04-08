##  NixOS Config

This repository provides a fully reproducible NixOS setup designed to get you from a fresh install to a fully working pentesting environment in under an hour.

Current test builds average ~25 minutes from live CD to fully configured system.

The configuration is structured for:

- Multiple team members
- Different hardware
- Different usernames
- Different hostnames
- Zero config conflicts

## Getting Started From Fresh Install

### 1. Install Git

Open the base system configuration:

sudo nano /etc/nixos/configuration.nix

Add the following inside:

environment.systemPackages = with pkgs; [
  git
];

Then run:

sudo nixos-rebuild switch
### 2. Clone The Repo
git clone <repo-url>
cd nixConfig

### 3. Generate Your Host

Run the host generator:

./scripts/new-host.sh

This will:

Ask for hostname

Ask for username

Detect your architecture

Create hosts/<hostname>/

Generate:

custom.nix

configuration.nix

home.nix

Optional: it can also set the system hostname for you.

### 4. Copy Hardware Configuration

After generating the host, copy your hardware config:

sudo cp /etc/nixos/hardware-configuration.nix ./hosts/<hostname>/

Replace <hostname> with your actual hostname.

###  5.Build The System

Run:

sudo nixos-rebuild switch --flake .#$(hostname)

Or manually:

sudo nixos-rebuild switch --flake .#<hostname>

The flake automatically detects all hosts inside hosts/.

No manual edits to flake.nix are required.

📂 Repository Structure
hosts/
 ├── <hostname>/
 │    ├── custom.nix
 │    ├── configuration.nix
 │    ├── hardware-configuration.nix
 │    └── home.nix
 └── common/
      └── base.nix

modules/
scripts/
flake.nix

Each team member has their own isolated host folder.

No conflicts.
No shared usernames.
No hardcoded values.

🔄 Rebuilding After Changes

Any time you update the repo:

sudo nixos-rebuild switch --flake .#$(hostname)
🧰 Tooling Setup
Nessus (Docker)

If the docker image fails to pull automatically:

sudo docker pull tenable/nessus:latest-ubuntu
🧠 Team Usage Model

Each team member:

Clones the repo

Runs ./scripts/new-host.sh

Copies hardware config

Builds using their hostname

The flake automatically builds only their configuration.