#!/usr/bin/env sh

apk update
apk add busybox-extras git openssh neovim vim \
  mksh fish ca-certificates \
  bash gcc musl-dev openssl \
  go fzf bats tar wget stow make curl python3 tmux

# this was lifted from the go dockerfile image
[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
        GOOS="$(go env GOOS)" \
        GOARCH="$(go env GOARCH)" \
        GOHOSTOS="$(go env GOHOSTOS)" \
        GOHOSTARCH="$(go env GOHOSTARCH)" \
        GOLANG_VERSION="1.12"

wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz";
tar -C /usr/local -xzf go.tgz;
rm go.tgz;
cd /usr/local/go/src;
./make.bash;
rm -rf /usr/local/go/pkg/bootstrap /usr/local/go/pkg/obj
export PATH="/usr/local/go/bin:$PATH" >> /home/vagrant/.profile;

# terraform
export TERRAFORM_VERSION=0.11.12
export TF_DEV=true
export TF_RELEASE=true
export GOPATH="$HOME/go"
mkdir -p "$GOPATH/src/github.com/hashicorp"
cd "$GOPATH/src/github.com/hashicorp"
git clone https://github.com/hashicorp/terraform.git && \
git checkout v${TERRAFORM_VERSION} && \
/bin/bash scripts/build.sh

# kubectl
cd $HOME
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
ln -S /usr/bin/kubectl $HOME/kubectl


# setup dotfiles
git clone https://github.com/hmgibson23/snippets.git
cd snippets && make stow

# fasd
wget https://github.com/clvv/fasd/tarball/1.0.1
tar -xzf 1.0.1 && cd clvv-fasd-4822024 && make install

# rust because I want ripgrep and rg
curl https://sh.rustup.rs -sSf | sh

# nvim plugins
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall
