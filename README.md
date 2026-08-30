## Personal Machine Ansible

Ansible playbooks for bootstrapping personal machines and servers: shell environment/dotfiles, CLI tooling, and (optionally) GUI apps.

## Layout

```
ansible.cfg                    # inventory path, python interpreter, etc.
inventory/hosts.ini            # host groups: [nixos] and [debian]
playbooks/
  local-bootstrap.yml          # dotfiles/shell env — runs on ALL hosts, any OS
  debian-packages.yml          # CLI packages — Debian/Ubuntu hosts only
  debian-gui-packages.yml      # GUI apps — Debian/Ubuntu hosts only, opt-in
files/                         # source files copied out by local-bootstrap.yml
  bashrc
  bash/gui-module.sh
  hyperjump/hyperjump.sh
run.sh                         # convenience wrapper for local-bootstrap.yml
```

## Playbooks

### `local-bootstrap.yml`
Targets `hosts: all` — runs against every host in the inventory regardless of OS, since it only touches the connecting user's home directory (`become: false`, no system config changes). Installs:
- `~/.bashrc`, `~/.bash_aliases` (aliases + helper functions like `git_go`, `ssh_add_keyfile`)
- the [hyperjump](files/hyperjump/README.md) directory-jump script into `~/.local/bin`
- the GUI bash module into `~/.config/bash`
- shared/timestamped bash history settings

All paths use `ansible_facts['env']['HOME']`, which is the **target host's** home directory (not the control machine's) — important since this repo runs against both `localhost` and remote hosts as different users (e.g. `root` on `borg-host`).

### `debian-packages.yml`
Targets the `[debian]` inventory group. Requires `become: true` (sudo/root) since it installs system packages. Installs:
- `git` and utility packages (`openssl`, `unzip`, `lsof`, `net-tools`, `parted`, `speedtest-cli`, `tree`, `tcpdump`, `rclone`)
- Docker Engine (`docker.io`) and adds the connecting user to the `docker` group
- AWS CLI v2 (official installer, downloaded/unzipped/installed only if not already present)
- Node.js/npm, then the Claude Code CLI (`@anthropic-ai/claude-code`) via npm

### `debian-gui-packages.yml`
Also targets `[debian]`, but is **not** run by default — run it explicitly on hosts that need a desktop environment. Installs:
- VS Code, Google Chrome, Spotify (each via their official apt repo + signing key)
- Slack and Microsoft Teams (`teams-for-linux`, a community client — Microsoft no longer ships a native Linux Teams app) via snap
- JetBrains IntelliJ IDEA Ultimate and DataGrip via snap (`classic` confinement; Ultimate requires a license)

`snapd` is installed/enabled as part of this playbook for the snap-based installs.

## Inventory

`inventory/hosts.ini` has two groups:
- `[nixos]` — `localhost` (this machine, NixOS, `ansible_connection=local`). Package installs aren't run here — NixOS packages are managed declaratively via `/etc/nixos/configuration.nix`, not apt.
- `[debian]` — remote Debian/Ubuntu hosts, connected to over SSH. Currently `borg-host`.

To add a remote host: connectivity requires SSH access (key-based) and Python 3 on the target (Ansible is agentless — nothing needs installing there beyond that). Add a line like:
```ini
[debian]
your-host ansible_host=<ip-or-hostname> ansible_user=<ssh-user>
```
If `ansible_user` isn't root, `debian-packages.yml`/`debian-gui-packages.yml` will need sudo — pass `--ask-become-pass` when running.

## Usage

Install Ansible:
```bash
# nixos
nix-shell -p ansible   # or add to configuration.nix

# debian/ubuntu
sudo apt install -y ansible
```

Run against everything in the inventory:
```bash
./run.sh                                      # local-bootstrap.yml only
ansible-playbook playbooks/local-bootstrap.yml
ansible-playbook playbooks/debian-packages.yml
ansible-playbook playbooks/debian-ssh.yml
ansible-playbook playbooks/debian-gui-packages.yml   # opt-in, GUI hosts only
```

Run against a single host:
```bash
ansible-playbook playbooks/local-bootstrap.yml --limit borg-host
ansible-playbook playbooks/debian-packages.yml --limit borg-host --ask-become-pass
ansible-playbook playbooks/debian-ssh.yml --limit borg-host
```

Run against a specific user on a multi-account host (e.g. both `root` and `nick` on the same physical machine):
```bash
ansible-playbook playbooks/local-bootstrap.yml --limit precision-5680-2023-nick
ansible-playbook playbooks/local-bootstrap.yml --limit precision-5680-2023-root
```

Run as root on a host using `ansible_connection=local` (where `ansible_user` is ignored — see note above):
```bash
sudo -H ansible-playbook playbooks/local-bootstrap.yml --limit localhost
```

Syntax-check a playbook without running it:
```bash
ansible-playbook playbooks/local-bootstrap.yml --syntax-check
```

Rerunning any playbook is safe — tasks are idempotent (package/`creates` checks, `blockinfile` markers, etc.).

## After bootstrapping a shell

Restart your shell to pick up the new dotfiles:
```bash
exec bash -l
```
Verify: `type ll`, `history`, `hyperjump` (if installed).
