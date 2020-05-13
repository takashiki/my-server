#!/bin/bash

# load config

if [ ! -f .env ]
then
	echo "must set config"
	exit
fi

export $(cat .env | sed 's/#.*//g' | xargs)

# install softwares

apt update
apt upgrade
apt install vim git

# ===
# config vim

git clone https://github.com/takashiki/my-vim.git ~/.vim
echo "source ~/.vim/my.vim" > ~/.vimrc

# ===
# config ssh port and key

echo "Port $SSH_PORT" >> /etc/ssh/sshd_config

if [ ! -d ~/.ssh ]
then
	mkdir ~/.ssh
	chmod 700 ~/.ssh
fi
cat $PUB_KEY >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

service ssh restart

# ===
# install docker

source /etc/os-release

apt remove docker docker-engine docker.io containerd runc

apt install \
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
apt install docker-ce docker-ce-cli containerd.io

docker run hello-wolrd

