# Matt Lee's Dotfiles

## Install

    cd ~
    git clone https://github.com/thatismatt/dotfiles.git
    cd dotfiles
    ./install
    # follow the prompts

## Requirements

    # Icons
    sudo apt-get install faenza-icon-theme
    cd Pictures
    git clone https://github.com/google/material-design-icons.git

    # fonts
    sudo apt-get install fonts-inconsolata
    sudo apt-get install fonts-vlgothic

## Other Software

    # urxvt
    sudo apt-get install rxvt-unicode-256color

    # Java - https://launchpad.net/~webupd8team/+archive/ubuntu/java
    sudo add-apt-repository ppa:webupd8team/java
    sudo apt-get update
    sudo apt-get install oracle-java7-installer
    sudo apt-get install oracle-java8-installer

    # lein - http://leiningen.org/
    cd bin
    wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    sudo chmod +x lein
