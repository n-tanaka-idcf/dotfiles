# starship の初期化スクリプトを vendor autoload ディレクトリに生成する。
# env.nu の時点では mise が有効化されていないため、mise exec 経由で実行する。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let starship_path = $autoload_dir | path join starship.nu
if (which mise | is-not-empty) {
  ^mise exec starship -- starship init nu | save --force $starship_path
} else {
  "" | save --force $starship_path
}
