# atuin の初期化スクリプトを vendor autoload ディレクトリに生成する。
# mise の shims は scripts/mise.nu で PATH に追加済み。
# Ctrl+R と上矢印キーで atuin の履歴検索が開く。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let atuin_path = $autoload_dir | path join atuin.nu
if (which atuin | is-not-empty) {
  ^atuin init nu | save --force $atuin_path
} else {
  "" | save --force $atuin_path
}
