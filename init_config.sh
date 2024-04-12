#!/bin/bash
sudo apt-get update && sudo apt-get -y upgrade

sudo apt-get -y install git \
	clang \
	cmake \
	ninja-build \
	gettext \
	unzip \
	curl \
	build-essential \
	tmux \
	docker

# get dot files
git clone https://github.com/syntaxDuck/.dotfiles.git ~/.config/.dotfiles

cp -a ~/.config/zsh/. ~/

cp -r ~/.config/.dotfiles/nvim ~/.config/nvim/

# Tmux
cp -r ~/.config/.dotfiles/tmux ~/.config/tmux/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Starship prompt
sudo curl -sS https://starship.rs/install.sh | sh
cp -r ~/.config/.dotfiles/starship/ ~/.config/starship

# Oh my zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions \
	${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Install repos
# - Neovim
mkdir ~/repos
git clone https://github.com/neovim/neovim ~/repos/neovim
cd ~/repos/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd ~
