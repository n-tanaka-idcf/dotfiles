# env.nu
#
# config.nu より先に読み込まれる。
# See https://www.nushell.sh/book/configuration.html

source ($nu.default-config-dir | path join scripts mise.nu)
source ($nu.default-config-dir | path join scripts atuin.nu)
source ($nu.default-config-dir | path join scripts carapace.nu)
source ($nu.default-config-dir | path join scripts starship.nu)
source ($nu.default-config-dir | path join scripts task.nu)
source ($nu.default-config-dir | path join scripts zoxide.nu)
