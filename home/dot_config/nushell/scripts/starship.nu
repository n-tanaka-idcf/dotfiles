# starship の初期化スクリプトを vendor autoload ディレクトリに生成する。
# 起動を速くするため、すでにあれば作り直さない。mise の設定か scripts/*.nu が変わると chezmoi apply で削除され、次の起動で作り直される。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
let starship_path = $autoload_dir | path join starship.nu
if not ($starship_path | path exists) and (which starship | is-not-empty) {
  mkdir $autoload_dir
  ^starship init nu | save $starship_path
}
