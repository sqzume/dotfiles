set -U fish_greeting

set -qU XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -qU XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -qU XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache
set -qU XDG_STATE_HOME; or set -Ux XDG_STATE_HOME $HOME/.local/state

set -gx QT_IM_MODULE "fcitx"
set -gx GLFW_IM_MODULE "ibus"
set -gx SDL_IM_MODULE "fcitx"

set -gx QT_QPA_PLATFORMTHEME "qt5ct"

# dotfiles
set -gx ANDROID_USER_HOME "$XDG_DATA_HOME/android"
set -gx GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -gx GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"

# starship
starship init fish | source

