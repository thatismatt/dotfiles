# Matt Lee's Dotfiles

## Install

    cd ~
    git clone https://github.com/thatismatt/dotfiles.git
    cd dotfiles
    ./install
    # follow the prompts

## Requirements

    # icons
    sudo apt install faenza-icon-theme
    cd Pictures
    git clone https://github.com/google/material-design-icons.git

    # fonts
    sudo apt install fonts-inconsolata
    sudo apt install fonts-vlgothic
    # Iosevka - https://github.com/be5invis/Iosevka

    # theme
    apt install greybird-gtk-theme

## Other Software

    # java - https://launchpad.net/~webupd8team/+archive/ubuntu/java
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt update
    sudo apt install oracle-java7-installer
    sudo apt install oracle-java8-installer

    # lein - http://leiningen.org/
    wget -qO- https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > ~/bin/lein
    chmod +x ~/bin/lein

    # apt packages
    sudo apt install rxvt-unicode-256color thunar evince feh arandr lxappearance tmux
