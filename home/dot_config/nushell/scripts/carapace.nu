# carapace の補完スクリプトを vendor autoload ディレクトリに生成する。
# 起動を速くするため、すでにあれば作り直さない。mise の設定か scripts/*.nu が変わると chezmoi apply で削除され、次の起動で作り直される。
# mise の shims は scripts/mise.nu で PATH に追加済み。
# carapace に補完がないコマンドは、インストール済みのほかのシェルの補完で代用する。
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
let autoload_dir = $nu.vendor-autoload-dirs | last
let carapace_path = $autoload_dir | path join carapace.nu
if not ($carapace_path | path exists) and (which carapace | is-not-empty) {
  mkdir $autoload_dir
  ^carapace _carapace nushell | save $carapace_path
}
