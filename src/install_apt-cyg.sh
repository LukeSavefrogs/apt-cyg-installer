#!/bin/env bash

# Styling
declare -r red='\033[0;31m';
declare -r green='\033[0;32m';
declare -r yellow='\033[0;33m';
declare -r default='\033[0m';
declare -r bold='\033[1m';
declare -r underlined="\033[4m";


declare -r NEW_BIN_NAME="apt-cyg";

trap 'rm -f "${NEW_BIN_NAME}"' EXIT;

main () {
	if command -v "${NEW_BIN_NAME}" >/dev/null 2>&1; then
		printf "${green}OK${default} - Program '%s' already installed\n\n" "${NEW_BIN_NAME}";

		return 0;
	fi

	if command -v "curl" >/dev/null 2>&1; then
		dw_program_bin="curl";
		dw_program_arg=(--silent --show-error --location --ssl-no-revoke --create-dirs --output "${NEW_BIN_NAME}");

	elif command -v "wget" >/dev/null 2>&1; then
		dw_program_bin="wget";
		dw_program_arg=(--quiet --output-document="${NEW_BIN_NAME}");

	else
		printf "${red}ERROR${default} - No executable found for downloading '%s'!\n\n" "${NEW_BIN_NAME}";
		printf "Aborted\n";

		return 1;
	fi
	
	printf "Downloading apt-cyg using '%s'... \t" "$dw_program_bin";
	
	$dw_program_bin "${dw_program_arg[@]}" "rawgit.com/transcode-open/apt-cyg/master/apt-cyg" || {
		printf "${red}ERROR${default} - Download of '%s' using '%s' failed.\n\n" "$NEW_BIN_NAME" "$dw_program_bin";

		return 2;
	}
	printf "${green}OK${default} - Download completed\n" "$NEW_BIN_NAME";

	printf "Installing apt-cyg as %s... \t" "$NEW_BIN_NAME";
	install "$NEW_BIN_NAME" /bin || {
		printf "${red}ERROR${default} - Installation of '%s' using 'install' failed.\n\n" "$NEW_BIN_NAME" "$dw_program_bin";

		return 3;
	}
	
	printf "${green}OK${default} - Installation of '%s' completed successfully!\n\n" "$NEW_BIN_NAME";
	
	printf "Generating autocompletion... \t\t";
	if create_autocompletions; then
		printf "${green}OK${default} - Autocompletion for '%s' successfully set!\n\n\n" "$NEW_BIN_NAME";
		printf "Restart your shell to apply the changes..\n\n";
	else
		printf "${yellow}WARNING${default} - Couldn't set autocompletions for '%s'\n\n" "$NEW_BIN_NAME"; 
	fi

	printf "Get started using: '%s help'\n\n" "$NEW_BIN_NAME"; 
	return 0;
}

function create_autocompletions () {
	possible_options=$(${NEW_BIN_NAME} | awk '
		BEGIN { 
			isHeader=0; 
			options=""; 
			optionsStarted=0; 
		}
		/^[^ \t]/{ 
			if ($1 ~ /OPERATIONS|OPTIONS/) optionsStarted=1; 
			else optionsStarted=0; 
		} 
		optionsStarted { 
			if ($0 ~ /^  [^ \t]/) { 
				gsub(/^[ \t]+/, "", $0); 
				
				options = sprintf ("%s %s", options, $0);
			} 
		}
		END {
			gsub(/^[ \t]+/, "", options); 
			gsub(/[ \t]+$/, "", options); 
			printf ("%s", options)
		}
	');

	[[ -d /etc/bash_completion.d ]] || {
		printf "${red}ERROR${default} - Sorry, directory '/etc/bash_completion.d' is not present on your system\n\n"
		return 1;
	}
	
	cd /etc/bash_completion.d || return 1;
	cat - > "${NEW_BIN_NAME}-completion" <<-EOF
		complete -W "${possible_options}" "${NEW_BIN_NAME}"
	EOF
}


main "$@"
