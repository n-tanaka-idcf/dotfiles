# env.nu
#
# config.nu より先に読み込まれる。
# See https://www.nushell.sh/book/configuration.html

source ($nu.default-config-dir | path join scripts mise.nu)
source ($nu.default-config-dir | path join scripts starship.nu)
