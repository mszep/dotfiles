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
alias oc="opencode"
alias ltr="ls -ltr"
alias jt="just test"

export EDITOR='nvim'

function awsauth -a profile
    set -q profile[1]
        or set profile "dev-poweruser"
    eval (aws configure export-credentials --profile $profile --format env)
end

function sso
    aws sso login --sso-session mszepieniec
end

function claude-litellm --description 'Run claude against the internal Litellm endpoint'
    set -x ANTHROPIC_BASE_URL "https://litellm.dev.xyme.cloud"
    set -x ANTHROPIC_AUTH_TOKEN "$XYME_LITELLM_API_KEY"
    claude $argv
end

# Initialise Homebrew (sets PATH, MANPATH, etc.). Guard on the binary existing on
# disk by absolute path -- `type -q brew` cannot work here because brew is not yet on
# PATH; running shellenv is what puts it there. Covers Apple Silicon and Intel; a no-op
# on Linux where neither path exists.
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

# opencode
fish_add_path /Users/mszepieniec/.opencode/bin
