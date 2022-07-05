#!/usr/bin/env bash

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -:.-"
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -:.+"

tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"

#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json


# tmux bind-key -T copy-mode-vi C-h select-pane -L
# tmux bind-key -T copy-mode-vi C-j select-pane -D
# tmux bind-key -T copy-mode-vi C-k select-pane -U
# tmux bind-key -T copy-mode-vi C-l select-pane -R
# tmux bind-key -T copy-mode-vi C-\\ select-pane -l

