#!/bin/bash

source "scripts/utils.sh"

trap stop_script INT

function show_banner() {
                                                         
    echo -e "  _____        _                 _____              _      "
    echo -e " |  ___|__  __| | ___  _ __ __ _|  ___| __ ___  ___| |__   "
    echo -e " | |_ / _ \/ _' |/ _ \| '__/ _' | |_ | '__/ _ \/ __| '_ \  "
    echo -e " |  _|  __/ (_| | (_) | | | (_| |  _|| | |  __/\__ \ | | | "
    echo -e " |_|  \___|\__,_|\___/|_|  \__,_|_|  |_|  \___||___/_| |_| \n"
    echo -e "Fedora: ${fedora_variant} v${fedora_version} - \n\n" 

}

function menu() {

    echo -e "(1) ${cyan}Install FedoraFresh${resetStyle}"
    echo -e "(2) ${cyan}Install GPU drivers (Nvidia e Intel)${resetStyle}"
    echo -e "(3) ${cyan}Install Multimedia${resetStyle}"
    echo -e "(4) ${cyan}Install Flatpak's${resetStyle}"
    echo -e "(0) ${cyan}Exit${resetStyle}\n"
}

function install() {
    clear
    echo -e "--> Empezando la instalacion ;)"; sleep 2
    clear
    echo -e "${purple}[!] Configurando DNF...${resetStyle}"; sleep 1
    #echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    checkRPMfusion
    installMultimedia
    sleep 1


}

function init(){

    
    clear
    if [[ $(id -u) = 0 || $(whoami) = "root" ]]; then

        echo -e "\n${red}[!] Ejecuta el script sin sudo\n${resetStyle}"
        exit 1
    else
        while true; do

            show_banner
            menu

            read -p "$(whoami) >> " opcion
            case $opcion in 
                1)
                    install
                    ;;
                2)
                    clear
                    install_multimedia
                    ;;
                3)
                    clear
                    install_flatpaks
                    ;;
                0)
                    exit 0
                    ;;
                *) 
                    echo -e "\n${red}[!] Opción no válida${resetStyle}"
                    echo -e "\nPresiona una tecla para continuar"
                    read -n 1 -s -r -p ""
                    clear
                    ;;
            esac
        done
    fi
    
}

init