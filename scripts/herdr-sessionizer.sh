#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/workspace -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected")

workspace_id=$(herdr workspace list | jq -r --arg name "$selected_name" \
    'first(.result.workspaces[] | select(.label == $name) | .workspace_id) // empty')

if [[ -n $workspace_id ]]; then
    herdr workspace focus "$workspace_id" >/dev/null
else
    herdr workspace create --cwd "$selected" --label "$selected_name" --focus >/dev/null
fi
