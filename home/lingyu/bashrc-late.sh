starship_precmd_user_func() {
    local new_config=""
    
    if [[ "$PWD" == /mnt/* ]]; then
	new_config="$HOME/.config/starship-simple.toml"
    fi
    
    if [[ "$STARSHIP_CONFIG" != "$new_config" ]]; then
	if [[ -n "$new_config" ]]; then
	    export STARSHIP_CONFIG="$new_config"
	else
	    unset STARSHIP_CONFIG
	fi
    fi
}
