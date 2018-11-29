#!/bin/bash

AFTER=${1:-yesterday}
BEFORE=$2

#GIT_LOG_CMD=(l) # = log --pretty=format:'%C(auto)%h %Cgreen%an%Creset %Cblue%ar%Creset %s %C(auto)%d' --graph
#GIT_LOG_CMD=(log --oneline --graph)
GIT_LOG_CMD=(log --pretty=format:"%C(auto)%h %Cgreen%an%Creset %Cblue%ai%Creset %s %C(auto)%d" --graph)

if [[ -z $BEFORE ]]
then
    TIME_RANGE="--after=$AFTER"
else
    TIME_RANGE="--after=$AFTER --before=$BEFORE"
fi

cd ~/projects
PROJECT_DIRS=`find . -name .git -exec dirname {} \; | sort`

for PROJECT_DIR in $PROJECT_DIRS
do
    pushd $PROJECT_DIR &> /dev/null
    echo
    echo $PROJECT_DIR
    git "${GIT_LOG_CMD[@]}" $TIME_RANGE --decorate
    popd &> /dev/null
done
