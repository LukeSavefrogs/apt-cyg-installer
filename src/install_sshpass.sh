#!/bin/env bash
function install_sshpass () {
	yellow="\033[0;33m";
	green="\033[0;32m";\
	red="\033[0;31m";
	default="\033[0m";
	
	which sshpass >/dev/null 2>&1 && {
		printf "${yellow}Nulla da fare qui${default}. SSHPASS risulta essere già installato sul sistema.\n\nEsco.\n"

		return 1;
	}

	printf "Download: ";
	downl_result=$(wget -q http://sourceforge.net/projects/sshpass/files/latest/download -O sshpass.tar.gz 2>&1) && printf "${green}OK${default}\n" || {
		printf "${red}Errore${default}\n\n";
		echo "$downl_result";
		return 1;
	}

	tar -xvf sshpass.tar.gz 
	cd sshpass-1.06 || {
		printf "${red}Directory non esistente${default}. Estrazione file .tar fallita\n\n";

		return 1;
	}

	printf "Configurazione: "
	confg_result=$(./configure 2>&1) || {
		printf "${red}Errore${default}\n\n";
		echo "$confg_result";

		return 1;
	}
	printf "${green}OK${default}\n";

	printf "Compilazione: ";
	compi_result=$($(which sudo >/dev/null 2>&1 && printf "sudo") make install 2>&1) || {
		printf "${red}Errore${default}\n\n";
		echo "$compi_result";

		return 1;
	}
	printf "${green}OK${default}\n";
		
	printf "${green}Installazione completata con successo${default}\n\n";
}

install_sshpass "$@";
