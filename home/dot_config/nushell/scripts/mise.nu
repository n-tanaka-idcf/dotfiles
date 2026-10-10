# mise の shims を PATH に追加し、env.nu と config.nu の中から mise のツールを使えるようにする。
let mise_data_dir = $env.MISE_DATA_DIR? | default ($env.HOME | path join .local share mise)
$env.PATH = $env.PATH | prepend ($mise_data_dir | path join shims) | uniq

# mise の有効化スクリプトを vendor autoload ディレクトリに生成する。
# 生成したスクリプトは env.nu と config.nu のあとに自動で読み込まれ、
# ディレクトリごとのツールや環境変数の切り替えを行う。
# 出力には起動時の PATH が埋め込まれるため、ほかの scripts/*.nu と違ってキャッシュせず毎回生成する。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let mise_path = $autoload_dir | path join mise.nu
if (which mise | is-not-empty) {
  ^mise activate nu | save --force $mise_path
} else {
  "" | save --force $mise_path
}
