#!/bin/bash

# Install Homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Brew already installed"
fi

brew update && brew upgrade

brew install ninja cmake gettext curl wget stow
brew install tmux

# sudo apt-get -y install git \
# 	clang \
# 	cmake \
# 	ninja-build \
# 	gettext \
# 	unzip \
# 	curl \
# 	build-essential \
# 	tmux \
# 	podman \
# 	ripgrep \
# 	fd-find \
# 	fzf \
# 	btop \
# 	neofetch \
# 	stow

start_dir=$PWD
stow .
cd ~

sudo npm install -g neovim

# Tmux package manager
DIRECTORY=~/.tmux/plugins/tpm
if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Rust Install
echo "############################################"
echo "INSTALL RUST                                "
echo "############################################"
if ! command -v cargo &>/dev/null; then
  echo "Downloading rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source ~/.zshrc
else
  echo "Rust already installed!..."
fi

# Go Install
echo "############################################"
echo "INSTALL GO                                  "
echo "############################################"

go_version="go1.22.5"
go_tar_file="$go_version.darwin%2Darm64.tar.gz"
go_url="https://go.dev/dl/$go_tar_file"
go_expected_hash="4cd1bcb05be03cecb77bccd765785d5ff69d79adf4dd49790471d00c06b41133"

if ! command -v go &>/dev/null; then
  echo "Downloading $go_version..."
  if ! curl -OL "$go_url"; then
    echo "WARNING: Failed to download $go_version from $go_version_url. Continuing..."
  else
    downloaded_hash=$(shasum -a 256 "$(basename $go_tar_file)" | awk '{print $1}')
    echo "Checking checksum..."
    echo "Downloaded hash: $downloaded_hash"
    echo "Expected hash: $go_expected_hash"

    if [[ "$downloaded_hash" != "$go_expected_hash" ]]; then
      echo "ERROR: Checksum didn't match for Go installation!"
      rm $go_tar_file
    else
      echo "Hashes matched. Verifying downloaded file..."
      if sudo tar -C /usr/local -xzf "$(basename $go_tar_file)"; then
        echo "Installation complete."
        rm "$(basename $go_tar_file)"
        export PATH=$PATH:/usr/local/go/bin                          # Update PATH for current session
        echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.bash_profile # Update PATH for future sessions
      else
        echo "ERROR: Failed to extract Go installation."
        rm $go_tar_file
      fi
    fi
  fi
else
  echo "Go is already installed."
fi

# zoxide
echo "############################################"
echo "INSTALL ZOXIDE                               "
echo "############################################"
if ! command -v zoxide &>/dev/null; then
  cargo install zoxide --locked
else
  echo "zoxide already installed"
fi

# lazygit
echo "############################################"
echo "INSTALL LAZYGIT                             "
echo "############################################"
if ! command -v lazygit &>/dev/null; then
  go install github.com/jesseduffield/lazygit@latest
else
  echo "lazygit already installed"
fi

# Starship prompt
echo "############################################"
echo "INSTALL STARSHIP                            "
echo "############################################"
if ! command -v starship &>/dev/null; then
  sudo curl -sS https://starship.rs/install.sh | sh
else
  echo "starship already installed"
fi

# Oh my zsh and plugins
echo "############################################"
echo "INSTALL OHMYZSH                             "
echo "############################################"
DIRECTORY=~/.oh-my-zsh/
if [ ! -d "$DIRECTORY" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed"
fi

# Get plugins
DIRECTORY=~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

DIRECTORY=~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo "############################################"
echo "INSTALL REPOS                               "
echo "############################################"
DIRECTORY=~/repos/
if [ ! -d "$DIRECTORY" ]; then
  mkdir ~/repos
fi

echo "--- INSTALL NEOVIM"
DIRECTORY=~/repos/neovim/
if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/neovim/neovim ~/repos/neovim
  cd ~/repos/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  sudo npm install -g neovim
else
  echo "neovim already installed"
fi

cd $start_dir
