# starship の初期化スクリプトを vendor autoload ディレクトリに生成する。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let starship_path = $autoload_dir | path join starship.nu
if (which starship | is-not-empty) {
  ^starship init nu | save --force $starship_path
} else {
  "" | save --force $starship_path
}
