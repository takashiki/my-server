#!/bin/bash

# install softwares

export DEBIAN_FRONTEND=noninteractive
apt update
apt -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
apt install -y curl vim git htop lrzsz autojump

# load config

if [ ! -f .env ]; then
	curl https://raw.fastgit.org/takashiki/my-server/master/.env.example -o .env
	curl https://raw.fastgit.org/takashiki/my-server/master/id_rsa.pub -o id_rsa.pub
fi

export $(cat .env | sed 's/#.*//g' | xargs)

# ===
# basic config & vim

if [ -n $GIT_USER ] && [ -n $GIT_EMAIL ]; then
	git config --global user.name $GIT_USER
	git config --global user.email $GIT_EMAIL
fi
git config --global credential.helper store

git clone https://gitclone.com/github.com/takashiki/my-server.git ~/.server
echo "for alias in ~/.server/aliases/*
	do . \$alias
done" >> ~/.bashrc

git clone https://gitclone.com/github.com/takashiki/my-vim.git ~/.vim
git clone https://gitclone.com/github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "source ~/.vim/my.vim" > ~/.vimrc

# ===
# config ssh port and key

if [ -n $SSH_PORT ]; then
	echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi

if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	chmod 700 ~/.ssh
fi

if [ -n $PUB_KEY_PATH ] && [ -f $PUB_KEY_PATH ]; then
	cat $PUB_KEY_PATH >> ~/.ssh/authorized_keys
	chmod 600 ~/.ssh/authorized_keys
fi

service ssh restart

# ===
# install docker

export $(cat /etc/os-release | grep ID | xargs)

apt remove docker docker-engine docker.io containerd runc

apt install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

curl -fsSL http://mirrors.tencentyun.com/docker-ce/linux/$ID/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository \
	"deb [arch=amd64] http://mirrors.tencentyun.com/docker-ce/linux/$ID \
	$(lsb_release -cs) \
	stable"

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose

if [ -n $DOCKER_MIRROR ]; then
	curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s $DOCKER_MIRROR
	service docker restart
fi

docker run hello-world
