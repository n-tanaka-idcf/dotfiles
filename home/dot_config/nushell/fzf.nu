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

# Pick paths of the given fd type (f or d) and insert them at the cursor,
# quoting paths with spaces.
def fzf-path-widget [type: string] {
    # Judge success by fzf alone: fd may get SIGPIPE once fzf exits.
    let result = (^fd --type $type --hidden --exclude .git | fzf --multi | complete)
    let selected = if $result.exit_code == 0 { $result.stdout | lines } else { [] }
    if ($selected | is-not-empty) {
        let paths = ($selected | each {|path| if ($path =~ '\s') { $"`($path)`" } else { $path } })
        commandline edit --insert ($paths | str join " ")
    }
}

# Emulate the Ctrl+X, Ctrl+F (file) and Ctrl+X, Ctrl+D (directory) chords:
# reedline has no multi-key bindings, so Ctrl+X runs this and reads the next
# key. Alt is avoided because macOS terminals turn Option+F into a character
# instead of sending Alt+F.
def fzf-chord-widget [] {
    let key = (input listen --types [key])
    if ($key.modifiers | to nuon) =~ "(?i)control" {
        match $key.code {
            "f" => { fzf-path-widget f }
            "d" => { fzf-path-widget d }
        }
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
            name: fzf_chord
            modifier: control
            keycode: char_x
            mode: [emacs vi_insert vi_normal]
            event: { send: executehostcommand, cmd: "fzf-chord-widget" }
        }
    ]
)
