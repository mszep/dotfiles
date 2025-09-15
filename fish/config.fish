if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias vv="source ./.venv/bin/activate.fish"
alias vim="nvim"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias k="kubectl"
alias pj="pbpaste | jq"
alias de="deactivate"
alias k="kubectl"

export EDITOR='nvim'

# Create an alias/function to set UV credentials
function uvauth
    set -gx TOKEN (aws codeartifact get-authorization-token \
        --domain xyme-internal \
        --domain-owner 390844779993 \
        --output text \
        --query authorizationToken \
        --profile dev-poweruser)

    set -gx UV_INDEX_XYME_PYPI_USERNAME aws
    set -gx UV_INDEX_XYME_PYPI_PASSWORD "$TOKEN"
end

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
