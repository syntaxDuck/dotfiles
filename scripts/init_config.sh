#!/bin/bash
set -e
start_dir=$PWD

install_packages_ubuntu() {
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
    docker \
    ripgrep \
    fd-find \
    fzf \
    btop \
    neofetch \
    stow \
    zsh \
    xclip
}

install_packages_macos() {
  brew update && brew upgrade

  brew install git \
    llvm \
    cmake \
    ninja \
    gettext \
    unzip \
    curl \
    tmux \
    podman \
    docker \
    ripgrep \
    fd \
    fzf \
    btop \
    neofetch \
    stow \
    zsh \
    xclip \
    node
}

install_oh_my_zsh() {
  if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    install_oh_my_zsh_plugins
  else
    echo "oh-my-zsh already installed"
  fi

}

install_oh_my_zsh_plugins() {
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

}

install_rust() {
  if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  else
    echo "Rust already installed"
  fi
}

install_golang() {
  local go_version="https://go.dev/dl/go1.22.2.linux-amd64.tar.gz"
  local go_expected_hash="5901c52b7a78002aeff14a21f93e0f064f74ce1360fce51c6ee68cd471216a17"

  if ! command -v go &>/dev/null; then
    cd $HOME
    curl -OL "$go_version"

    downloaded_hash=$(sha256sum $(basename $go_version) | awk '{print $1}')
    if [[ "$downloaded_hash" == "$go_expected_hash" ]]; then
      sudo tar -C /usr/local -xvf $(basename $go_version)
      rm (basename $go_version)
      source $HOME/.zshrc
    else
      echo "ERROR: Checksum didn't match for Go installation!!"
    fi
  else
    echo "Go already installed"
  fi
}

install_zoxide() {
  if ! command -v cargo &>/dev/null; then
    if ! command -v zoxide &>/dev/null; then
      cargo install zoxide --locked
    else
      echo "zoxide already installed"
    fi
  else
    echo "Rust cargo is required for installation"
  fi
}

install_lazygit() {
  if ! command -v go &>/dev/null; then
    if ! command -v lazygit &>/dev/null; then
      go install github.com/jesseduffield/lazygit@latest
    else
      echo "lazygit already installed"
    fi
  else
    echo "golang is required for installation"
  fi
}

install_tmux_plugins() {
  if command -v tmux &>/dev/null; then
    if [! -d "$HOME/.tmux/plugins/tpm"]; then
      git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    else
      echo "tmux plugins already installed"
    fi
  else
    echo "tmux plugins already installed"
  fi
}

install_starship() {
  if ! command -v starship &>/dev/null; then
    sudo curl -sS https://starship.rs/install.sh | sh -s -- -y
  else
    echo "starship already installed"
  fi
}

install_repos() {
  DIRECTORY=$HOME/repos/
  if [ ! -d "$DIRECTORY" ]; then
    mkdir ~/repos
  fi

  install_repo_neovim

}

install_repo_neovim() {
  local nvim_repo_dir=$HOME/repos/neovim/
  if [ ! -d "$nvim_repo_dir" ]; then
    git clone https://github.com/neovim/neovim $nvim_repo_dir
  else
    cd $nvim_repo_dir
    git pull
  fi

  cd $nvim_repo_dir
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  sudo npm install -g neovim
}

show_menu() {
  echo "Select components to install:"
  echo "1) Essential packages"
  echo "2) Oh My Zsh and plugins"
  echo "3) Rust"
  echo "4) Go"
  echo "5) Zoxide"
  echo "6) Lazygit"
  echo "7) Tmux plugins"
  echo "8) Starship"
  echo "9) Repos (Neovim)"
  echo "A) All"
  echo "0) Exit"
}

read_choice() {
  local choice
  read -p "Enter your choice [0-9, A]: " choice
  case $choice in
    1) install_packages ;;
    2) install_oh_my_zsh ;;
    3) install_rust ;;
    4) install_golang ;;
    5) install_zoxide ;;
    6) install_lazygit ;;
    7) install_tmux_plugins ;;
    8) install_starship ;;
    9) install_repos ;;
    A|a)
      install_packages
      install_oh_my_zsh
      install_rust
      install_golang
      install_zoxide
      install_lazygit
      install_tmux_plugins
      install_starship
      install_repos
      ;;
    0) exit 0 ;;
    *) echo "Invalid choice, please try again." ;;
  esac
}

main() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages=install_packages_ubuntu
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages=install_packages_macos
  else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
  fi

  cd $HOME/.dotfiles
  stow . -t $HOME

  while true; od
    show_menu
    read_choice
  doen
}

main
cd $PWD
