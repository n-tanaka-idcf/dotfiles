# env.nu
#
# Installed by:
# version = "0.101.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

# ------------------------------------------------------------------------------
# Environmet variables
# ------------------------------------------------------------------------------
$env.EDITOR = 'nvim'
$env.PATH = (
  $env.PATH
  | split row (char esep)
  # TODO: REPLACE
  | prepend '/opt/homebrew/bin'
  | uniq
)

# ------------------------------------------------------------------------------
# Cache
# ------------------------------------------------------------------------------
if not ($nu.cache-dir | path exists) { mkdir $nu.cache-dir }

# ------------------------------------------------------------------------------
# Atuin
# ------------------------------------------------------------------------------
let config_path = $nu.cache-dir | path join 'atuin.nu'
if not ($config_path | path exists) { atuin init nu | save -f $config_path }

# ------------------------------------------------------------------------------
# Carapace
# ------------------------------------------------------------------------------
# $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
let config_path = $nu.cache-dir | path join 'carapace.nu'
if not ($config_path | path exists) { carapace _carapace nushell | save -f $config_path }

# ------------------------------------------------------------------------------
# Starship
# ------------------------------------------------------------------------------
let config_path = $nu.cache-dir | path join 'starship.nu'
if not ($config_path | path exists) { starship init nu | save -f $config_path }

# ------------------------------------------------------------------------------
# Zoxide
# ------------------------------------------------------------------------------
let config_path = $nu.cache-dir | path join 'zoxide.nu'
if not ($config_path | path exists) { zoxide init nushell --no-cmd | save -f $config_path }
