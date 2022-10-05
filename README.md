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
    cd ~/Pictures
    git clone https://github.com/google/material-design-icons.git

    # fonts
    sudo apt install fonts-inconsolata
    sudo apt install fonts-vlgothic
    # Iosevka - https://github.com/be5invis/Iosevka

    # theme
    apt install greybird-gtk-theme

## Other Software

    # java
    sudo apt install oracle-java7-installer
    sudo apt install oracle-java8-installer

    # clojure - https://clojure.org/guides/getting_started
    curl -O https://download.clojure.org/install/linux-install.sh
    chmod +x linux-install.sh
    sudo ./linux-install.sh

    # lein - http://leiningen.org/
    wget -qO- https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > ~/bin/lein
    chmod +x ~/bin/lein

    # apt packages
    sudo apt install rxvt-unicode-256color thunar evince feh arandr lxappearance
