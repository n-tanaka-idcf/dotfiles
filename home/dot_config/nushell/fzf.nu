# fzf integration. Sourced from config.nu.
# nushell has no `fzf --nu`, so the environment and keybindings are defined here.

$env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"
$env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --exclude .git"

# Search history and replace the command line with the selection.
def fzf-history-widget [] {
    # fzf exits non-zero when cancelled, so only accept the selection on success.
    let result = (
        history
        | get command
        | reverse
        | uniq
        | str join (char nl)
        | fzf --scheme=history --query (commandline)
        | complete
    )
    let selected = if $result.exit_code == 0 { $result.stdout | str trim } else { "" }
    if ($selected | is-not-empty) {
        commandline edit --replace $selected
    }
}

# Pick files with fd and insert them at the cursor, quoting paths with spaces.
def fzf-file-widget [] {
    # Judge success by fzf alone: fd may get SIGPIPE once fzf exits.
    let result = (^fd --type f --hidden --exclude .git | fzf --multi | complete)
    let selected = if $result.exit_code == 0 { $result.stdout | lines } else { [] }
    if ($selected | is-not-empty) {
        let paths = ($selected | each {|path| if ($path =~ '\s') { $"`($path)`" } else { $path } })
        commandline edit --insert ($paths | str join " ")
    }
}

# Append, never assign, so bindings from config.nu and other files are kept.
$env.config.keybindings = (
    $env.config.keybindings
    | append [
        {
            name: fzf_history
            modifier: control
            keycode: char_r
            mode: [emacs vi_insert vi_normal]
            event: { send: executehostcommand, cmd: "fzf-history-widget" }
        }
        {
            name: fzf_file
            modifier: alt
            keycode: char_f
            mode: [emacs vi_insert vi_normal]
            event: { send: executehostcommand, cmd: "fzf-file-widget" }
        }
    ]
)
