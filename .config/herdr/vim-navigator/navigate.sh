#!/usr/bin/env bash
# Herdr side of vim-tmux-navigator: forward Ctrl+h/j/k/l to Vim/Neovim/fzf,
# otherwise move herdr's pane focus.

direction=$1
case $direction in
    left) key=ctrl+h ;;
    down) key=ctrl+j ;;
    up) key=ctrl+k ;;
    right) key=ctrl+l ;;
    *) exit 2 ;;
esac

# HERDR_BIN_PATH goes stale after `herdr update` replaces the running binary.
herdr=${HERDR_BIN_PATH:-herdr}
[[ -x $herdr ]] || herdr=herdr
pane=${HERDR_PANE_ID:?}

if "$herdr" pane process-info --pane "$pane" | jq -e '
    .result.process_info.foreground_processes[]?.name
    | select(test("^g?(view|l?n?vim?x?|fzf)(diff)?$"; "i"))' >/dev/null; then
    exec "$herdr" pane send-keys "$pane" "$key"
fi

exec "$herdr" pane focus --direction "$direction" --pane "$pane"
