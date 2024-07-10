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
  btop \
  neofetch \
  stow \
  zsh \
  xclip

start_dir=$PWD

go_version="https://go.dev/dl/go1.22.2.linux-amd64.tar.gz"
go_expected_hash="5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17"

stow .
cd ~

# Oh my zsh and plugins
echo "\n############################################"
echo "INSTALL OHMYZSH                             "
echo "############################################\n"
FILE=~/.oh-my-zsh/oh-my-zsh.sh
if [ ! -f "$FILE" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  # Get plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
  echo "oh-my-zsh already installed"
fi

# Rust Install
echo "\n############################################"
echo "INSTALL RUST                                "
echo "############################################\n"
if ! command -v cargo &>/dev/null; then
  echo "Downloading rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source ~/.zshrc
else
  echo "Rust already installed"
fi

# Go Install
echo "\n############################################"
echo "INSTALL GO                                  "
echo "############################################\n"
if ! command -v go &>/dev/null; then
  cd ~
  echo "Downloading $go_version..."
  curl -OL $go_version

  downloaded_hash=$(sha256sum $(basename $go_version) | awk '{print $1}')
  echo "Checking checksum..."
  echo "Downloaded hash: \t$downloaded_hash"
  echo "Expected hash: \t\t$go_expected_hash"

  if [[ "$downloaded_hash" == "$go_expected_hash" ]]; then
    echo "Hashes matched. Verifying downloaded file..."
    if [ -f $(basename $go_version) ]; then
      echo "File exists. Installing..."
      sudo tar -C /usr/local -xvf $(basename $go_version)
      echo "Installation complete."
      rm ~/$go_version
      source ~/.zshrc
    else
      echo "ERROR: Downloaded file not found."
    fi
  else
    echo "ERROR: Checksum didn't match for Go installation!!"
  fi
else
  echo "Go already installed"
fi

# zoxide
echo "\n############################################"
echo "INSTALL ZOXIDE                               "
echo "############################################\n"
if ! command -v zoxide &>/dev/null; then
  cargo install zoxide --locked
else
  echo "zoxide already installed"
fi

# lazygit
echo "\n############################################"
echo "INSTALL LAZYGIT                             "
echo "############################################\n"
if ! command -v lazygit &>/dev/null; then
  go install github.com/jesseduffield/lazygit@latest
else
  echo "lazygit already installed"
fi

# Tmux
echo "\n############################################"
echo "INSTALL TMUX                                "
echo "############################################\n"
if ! command -v lazygit &>/dev/null; then
  cp -r ~/.config/.dotfiles/tmux ~/.config/tmux/
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "tmux already installed"
fi

# Starship prompt
echo "\n############################################"
echo "INSTALL STARSHIP                            "
echo "############################################\n"
if ! command -v starship &>/dev/null; then
  sudo curl -sS https://starship.rs/install.sh | sh
  cp -r ~/.config/.dotfiles/starship/ ~/.config/starship
else
  echo "starship already installed"
fi

echo "\n############################################"
echo "INSTALL REPOS                               "
echo "############################################\n"
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
