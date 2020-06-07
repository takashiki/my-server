#!/bin/bash

# load config

if [ -f .env ]; then
	export $(cat .env | sed 's/#.*//g' | xargs)
fi

# install softwares

export DEBIAN_FRONTEND=noninteractive
apt update
apt -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
apt install -y vim git

if [ -z $GIT_USER ] && [ -z $GIT_EMAIL ]; then
	git config --global user.name takashiki
	git config --global user.email 857995137@qq.com
fi
git config --global credential.helper store

# ===
# basic config & vim

git clone https://github.com/takashiki/my-server.git ~/.server
echo "for alias in ~/.server/aliases/*
	do . \$alias
done" >> ~/.bashrc

git clone https://github.com/takashiki/my-vim.git ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "source ~/.vim/my.vim" > ~/.vimrc

# ===
# config ssh port and key

if [ ! -z $SSH_PORT ]; then
	echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi

if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	chmod 700 ~/.ssh
fi

if [ ! -z $PUB_KEY ] && [ -f $PUB_KEY ]; then
	cat $PUB_KEY >> ~/.ssh/authorized_keys
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

curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/$ID \
	$(lsb_release -cs) \
	stable"

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose

docker run hello-wolrd
