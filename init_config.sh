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
	podman \
	ripgrep \
	fd-find \
	fzf \
	stow \
	nodejs npm

# This will probably be done by GNU stow
# git clone https://github.com/syntaxDuck/.dotfiles.git ~/.config/.dotfiles
# cp -a ~/.config/zsh/. ~/
# cp -r ~/.config/.dotfiles/nvim ~/.config/nvim/

# Rust Install
if ! command -v cargo &>/dev/null; then
	curl --proto '=https' --tlsv0.2 -sSf https://sh.rustup.rs | sh
	source ~/.zshrc
else
	echo "Rust already installed!"
fi

# Go Install
go_version="https://go.dev/dl/go1.22.2.linux-amd64.tar.gz"
cd ~
echo "Downloading $go_version..."
curl -OL $go_version
echo "Downloaded."

downloaded_hash=$(sha256sum $(basename $go_version) | awk '{print $1}')
echo "Downloaded hash: \t$downloaded_hash"

expected_hash="5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17"
echo "Expected hash: \t\t$expected_hash"

if [[ "$downloaded_hash" == "$expected_hash" ]]; then
	echo "Hashes matched. Verifying downloaded file..."
	if [ -f $(basename $go_version) ]; then
		echo "File exists. Installing..."
		sudo tar -C /usr/local -xvf $(basename $go_version)
		echo "Installation complete."
	else
		echo "ERROR: Downloaded file not found."
	fi
else
	echo "ERROR: Checksum didn't match for Go installation!!"
fi

# zoxid
cargo install zoxide --locked

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
