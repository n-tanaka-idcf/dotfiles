# atuin の初期化スクリプトを vendor autoload ディレクトリに生成する。
# 起動を速くするため、すでにあれば作り直さない。mise の設定か scripts/*.nu が変わると chezmoi apply で削除され、次の起動で作り直される。
# mise の shims は scripts/mise.nu で PATH に追加済み。
# Ctrl+R と上矢印キーで atuin の履歴検索が開く。
let autoload_dir = $nu.vendor-autoload-dirs | last
let atuin_path = $autoload_dir | path join atuin.nu
if not ($atuin_path | path exists) and (which atuin | is-not-empty) {
  mkdir $autoload_dir
  ^atuin init nu | save $atuin_path
}

# 入力中のコマンドの続きを atuin の履歴からインラインヒント（灰色の文字）で表示する。
# カーソルが行末にあり、2 文字以上入力したときだけ、入力中の文字列で始まる最新のコマンドを探す。
# atuin が失敗したとき（$ATUIN_SESSION が未設定など）はヒントを出さず、結果も覚えない。
#
# キーを押すたびに atuin を起動すると遅いため、直前の検索結果を stor（nushell 内のメモリ上の SQLite）に覚えておく。
# 入力が前回の検索文字列の続きで、前回の結果（見つからなかった場合も含む）がまだ当てはまるなら、atuin を呼ばずに使い回す。
# コマンドを実行すると履歴が増えるため、pre_execution フックでキャッシュを消す。
stor open | query db "create table if not exists atuin_hint (line text, cmd text)" | ignore
$env.config.hooks.pre_execution = $env.config.hooks.pre_execution | append {||
  stor open | query db "delete from atuin_hint" | ignore
}
$env.config.hinter.closure = {|ctx|
  let line = $ctx.line
  let len = $line | str length
  if $len < 2 or $ctx.pos != $len { return null }
  let cached = stor open | query db "select line, cmd from atuin_hint" | get 0?
  let reusable = $cached != null and ($line | str starts-with $cached.line) and ($cached.cmd == null or ($cached.cmd | str starts-with $line))
  let cmd = if $reusable {
    $cached.cmd
  } else {
    let found = do -i { ^atuin search --cmd-only --limit 1 --search-mode prefix -- $line } | complete
    # 見つからないときも終了コードは 1 になるため、stderr に出力があるときだけ失敗とみなす。
    if $found.exit_code != 0 and ($found.stderr | is-not-empty) { return null }
    let cmd = $found.stdout | lines | get 0?
    let cmd = if $cmd != null and ($cmd | str starts-with $line) { $cmd }
    stor open | query db "delete from atuin_hint" | ignore
    stor open | query db "insert into atuin_hint (line, cmd) values (?, ?)" --params [$line $cmd] | ignore
    $cmd
  }
  if $cmd == null { return null }
  $cmd | str substring $len..
}
