parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)$ /'
}

PS1+="\[\033[33m\]\$(parse_git_branch)\[\033[00m\]"
export PS1

eval "$(direnv hook bash)"

hydra-rev() {
    hydra-job-revision $(hydra-check $1 --url | cut -d/ -f 5-)
}

hydra-job-revision() {
    local jobseteval job=$1
    shift 1
    case "$job" in
        *'/'*) ;;
        *) job="nixpkgs/trunk/$job" ;;
    esac
    case "$job" in
        'http://'*|'https://'*) ;;
        *) job="https://hydra.nixos.org/job/$job" ;;
    esac
    jobseteval=$(curl -fsSL -H 'Content-Type: application/json' "$job/latest" | jq '.jobsetevals[0]')
    curl -fsSL -H 'Accept: application/json' "${job%/job*}/eval/$jobseteval" | jq -r '.jobsetevalinputs.nixpkgs.revision'
}

nli() {
    nix-linter -r $PWD
}

fzf-store() {
    find /nix/store -mindepth 1 -maxdepth 1 -type d | fzf -m --preview-window right:50% --preview 'nix-store -q --tree {}'
}

alias nf="nixpkgs-fmt"
