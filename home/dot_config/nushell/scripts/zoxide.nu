# zoxide の初期化スクリプトを vendor autoload ディレクトリに生成する。
# 起動を速くするため、すでにあれば作り直さない。mise の設定か scripts/*.nu が変わると chezmoi apply で削除され、次の起動で作り直される。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
let zoxide_path = $autoload_dir | path join zoxide.nu
if not ($zoxide_path | path exists) and (which zoxide | is-not-empty) {
  mkdir $autoload_dir
  ^zoxide init nushell | save $zoxide_path
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
