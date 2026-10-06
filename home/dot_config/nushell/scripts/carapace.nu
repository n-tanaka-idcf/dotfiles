# carapace の補完スクリプトを vendor autoload ディレクトリに生成する。
# mise の shims は scripts/mise.nu で PATH に追加済み。
# carapace に補完がないコマンドは、インストール済みのほかのシェルの補完で代用する。
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let carapace_path = $autoload_dir | path join carapace.nu
if (which carapace | is-not-empty) {
  ^carapace _carapace nushell | save --force $carapace_path
} else {
  "" | save --force $carapace_path
}
