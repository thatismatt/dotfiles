#!/usr/bin/env fish

function path-add
    if test -d $argv
        set -x PATH $PATH $argv
    end
end

path-add ~/bin
path-add ~/.local/bin
path-add ~/scripts
path-add ~/opt/gradle/latest/bin
path-add ~/opt/maven/latest/bin
path-add ~/code/fennel

alias l "ls -la"
set fish_color_cwd 0a0
set fish_color_cwd_root c00
set fish_color_search_match --background=333
set fish_prompt_pwd_dir_length 0 # don't truncate
