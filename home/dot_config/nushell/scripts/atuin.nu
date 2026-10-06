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

# 入力中のコマンドの続きを atuin の履歴からインラインヒント（灰色の文字）で表示する。
# カーソルが行末にあるときだけ、入力中の文字列で始まる最新のコマンドを探す。
# atuin が失敗したとき（$ATUIN_SESSION が未設定など）はヒントを出さない。
$env.config.hinter.closure = {|ctx|
  if $ctx.line == "" or $ctx.pos != ($ctx.line | str length) { return null }
  let found = do -i { ^atuin search --cmd-only --limit 1 --search-mode prefix -- $ctx.line } | complete
  if $found.exit_code != 0 { return null }
  let cmd = $found.stdout | lines | get 0?
  if $cmd == null or not ($cmd | str starts-with $ctx.line) { return null }
  $cmd | str substring ($ctx.line | str length)..
}
