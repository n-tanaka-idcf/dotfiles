# zoxide の初期化スクリプトを vendor autoload ディレクトリに生成する。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let zoxide_path = $autoload_dir | path join zoxide.nu
if (which zoxide | is-not-empty) {
  ^zoxide init nushell | save --force $zoxide_path
} else {
  "" | save --force $zoxide_path
}

# Ctrl+J で zi（zoxide の対話的なディレクトリ選択）を実行する。
# zi は上で生成した初期化スクリプトで定義され、キーを押した時点で呼び出される。
$env.config.keybindings ++= [
  {
    name: zoxide_zi
    modifier: control
    keycode: char_j
    mode: [emacs vi_normal vi_insert]
    event: {
      send: executehostcommand
      cmd: "zi"
    }
  }
]
