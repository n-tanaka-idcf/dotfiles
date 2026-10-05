# mise の有効化スクリプトを vendor autoload ディレクトリに生成する。
# 生成したスクリプトは env.nu と config.nu のあとに自動で読み込まれる。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let mise_path = $autoload_dir | path join mise.nu
if (which mise | is-not-empty) {
  ^mise activate nu | save --force $mise_path
} else {
  "" | save --force $mise_path
}
