# task の補完スクリプトを vendor autoload ディレクトリに生成する。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
mkdir $autoload_dir
let task_path = $autoload_dir | path join task.nu
if (which task | is-not-empty) {
  ^task --completion nushell | save --force $task_path
} else {
  "" | save --force $task_path
}
