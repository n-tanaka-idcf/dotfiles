# task の補完スクリプトを vendor autoload ディレクトリに生成する。
# 起動を速くするため、すでにあれば作り直さない。mise の設定か scripts/*.nu が変わると chezmoi apply で削除され、次の起動で作り直される。
# mise の shims は scripts/mise.nu で PATH に追加済み。
let autoload_dir = $nu.vendor-autoload-dirs | last
let task_path = $autoload_dir | path join task.nu
if not ($task_path | path exists) and (which task | is-not-empty) {
  mkdir $autoload_dir
  ^task --completion nushell | save $task_path
}
