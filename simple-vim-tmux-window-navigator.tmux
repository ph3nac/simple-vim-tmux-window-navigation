#!/usr/bin/env bash

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

# if you use fig use this is_vim 

# is_vim="children=(); i=0; pids=( $(ps -o pid=,tty= | grep -iE '#{s|/dev/||:pane_tty}' | awk '\{print $1\}') ); \
# while read -r c p; do [[ -n c && c -ne p && p -ne 0 ]] && children[p]+=\" $\{c\}\"; done <<< \"$(ps -Ao pid=,ppid=)\"; \
# while (( $\{#pids[@]\} > i )); do pid=$\{pids[i++]\}; pids+=( $\{children[pid]-\} ); done; \
# ps -o state=,comm= -p \"$\{pids[@]\}\" | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"



bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -t:.-'
bind-key -n 'C-l 'if-shell "$is_vim" 'send-keys C-l' 'select-pane -t:.+'


#echo "{'version' : '${tmux_version}', 'sed_pat' : '${version_pat}' }" > ~/.tmux_version.json


# tmux bind-key -T copy-mode-vi C-h select-pane -L
# tmux bind-key -T copy-mode-vi C-j select-pane -D
# tmux bind-key -T copy-mode-vi C-k select-pane -U
# tmux bind-key -T copy-mode-vi C-l select-pane -R
# tmux bind-key -T copy-mode-vi C-\\ select-pane -l

