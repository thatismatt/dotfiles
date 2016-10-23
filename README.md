# Matt Lee's Dotfiles

## Install

    cd ~
    git clone https://github.com/thatismatt/dotfiles.git
    cd dotfiles
    ./install
    # follow the prompts

## Requirements

    # mpd
    sudo apt-get install mpd
    sudo apt-get install lua-socket

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

    # sbt - http://www.scala-sbt.org/download.html
    echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
    sudo apt-get update
    sudo apt-get install sbt

    # lein - http://leiningen.org/
    cd bin
    wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    sudo chmod +x lein
