#!/bin/bash

function git-status {
    cd $1
    printf "\033[0;34m$1\033[0m\n"
    git status -bs
}

git-status ~/dotfiles/
git-status ~/.config/awesome/
git-status ~/.emacs.d/
git-status ~/notes/
