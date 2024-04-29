#/usr/env sh

ccomp -std=c99 -fnone -Wall -O0 -dparse -dc -dclight -dcminor "$@"

ccomp -interp -trace "$@"
