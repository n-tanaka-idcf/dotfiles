def custom-keybindings [] {
  [
    {
      name: zoxide
      modifier: control
      keycode: char_j
      mode: [emacs vi_insert vi_normal]
      event: {
        send: ExecuteHostCommand
        cmd: "__zoxide_zi (commandline) | commandline edit --replace ''"
      }
    }
  ]
}
