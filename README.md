## Personal User Bootstrap

* restores your personal shell environment bash ssh keys aliases prompt history ssh-agent
* does not modify any system configuration

# 1 clone the repo
`git clone <your-repo-url> ~/ansible`
`cd ~/ansible/personal`

# 2 install ansible

# nixos
`nix-shell -p ansible`

# debian ubuntu
`sudo apt update`
`sudo apt install -y ansible`

# fedora
`sudo dnf install -y ansible`

`ansible --version`

# 3 run bootstrap
`ansible-playbook playbooks/local-bootstrap.yml --ask-vault-pass`

# 4 restart your shell
`exec bash -l`

# 5 verify environment
`type ll`
`ssh-add -l`
`parse_git_branch`
`history`

# rerun anytime
`cd ~/ansible/personal`
`ansible-playbook playbooks/local-bootstrap.yml --ask-vault-pass`

# vault maintenance
`ansible-vault edit files/ssh/id_ed25519`
`ansible-vault rekey files/ssh/id_ed25519`
