if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias vv="source ./.venv/bin/activate.fish"
alias vim="nvim"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias grw="gh run watch"
alias gpvw="gh pr view --web"
alias k="kubectl"
alias pj="pbpaste | jq"
alias de="deactivate"

export EDITOR='nvim'

function awsauth -a profile
    set -q profile[1]
        or set profile "dev-poweruser"
    eval (aws configure export-credentials --profile $profile --format env)
end

function sso 
    aws sso login --sso-session mszepieniec
end

eval "$(/opt/homebrew/bin/brew shellenv)"

# opencode
fish_add_path /Users/mszepieniec/.opencode/bin
