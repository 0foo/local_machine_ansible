## Personal User Bootstrap

* restores personal shell environment 
    * bash configure, aliases, prompt config, history, etc.
* does not modify any system configuration

## 1 clone the repo
`git clone <your-repo-url> ~/ansible`  
`cd ~/ansible/personal`

## 2 install ansible

### nixos
`nix-shell -p ansible` or add to configuration files

### debian ubuntu
`sudo apt update`  
`sudo apt install -y ansible`

### fedora
`sudo dnf install -y ansible`

`ansible --version`

## 3 run bootstrap
`./run.sh` from the root of this repo  
or  
`ansible-playbook playbooks/local-bootstrap.yml`

## 4 restart your shell
`exec bash -l`

## 5 verify environment
`type ll`   
`parse_git_branch`  
`history`  

## rerun anytime
`cd ~/ansible/personal`  
`ansible-playbook playbooks/local-bootstrap.yml`  
