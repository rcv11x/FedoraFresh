#!/bin/bash

#source "spinner.sh"

# -- Colors -- #

resetStyle="\e[0m"
red="\e[0;31m"
blue="\e[0;34m"
cyan="\e[0;36m"
green="\e[0;32m"
yellow="\e[0;33m"
purple="\e[0;35m"
white="\e[0;37m"
black="\e[0;30m"

fedora_version="40"

trap stop_script INT

function stop_script() {
    clear
    echo -e "\n${red}[!] Has salido del script \n${resetStyle}"
    exit 1
}

function msg_ok() {
    echo -e "${red}[${white} OK ${red}] ${resetStyle}\n"
}

function checkRPMfusion() {
    if [[ -f /etc/yum.repos.d/rpmfusion-free.repo || -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
        echo "[!] Los repositorios de RPM Fusion ya están instalados"
        msg_ok
        clear
    else
        sleep 5
        echo
        echo -e "\n${purple}[!] Añadiendo repositorio RPM Fusión...${resetStyle}\n"
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm > /dev/null 2>&1
        echo
    fi
}

function check_intel_or_amd_cpu() {

    if grep -q "Intel" /proc/cpuinfo; then

        echo -e "\n${purple}[!] CPU Intel detectado, instalando codecs necesarios...${resetStyle}\n"
        sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing

    elif grep -q "AMD" /proc/cpuinfo; then
    
        echo -e "\n${purple}[!] CPU AMD detectado, instalando codecs necesarios...${resetStyle}\n"
        sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    else
        echo "CPU no reconocido"
        
    fi

}


function show_banner() {
                                                         
    echo -e "  _____        _                 _____              _      "
    echo -e " |  ___|__  __| | ___  _ __ __ _|  ___| __ ___  ___| |__   "
    echo -e " | |_ / _ \/ _' |/ _ \| '__/ _' | |_ | '__/ _ \/ __| '_ \  "
    echo -e " |  _|  __/ (_| | (_) | | | (_| |  _|| | |  __/\__ \ | | | "
    echo -e " |_|  \___|\__,_|\___/|_|  \__,_|_|  |_|  \___||___/_| |_| \n\n"

}

function menu() {

    echo -e "\n[*] (1) Instalar FedoraFresh"
    echo -e "[*] (2) Instalar Multimedia"
    echo -e "[*] (0) Salir\n"
}

function install() {
    clear
    echo -e "--> Empezando la instalacion ;)"; sleep 3
    echo
    echo -e "\n${purple}[!] Configurando DNF...${resetStyle}\n"
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    checkRPMfusion

}

function installMultimedia() {

    clear
    echo -e "* Por defecto Fedora $(fedora_version) proporciona unicamente drivers free que suelen carecer de muchas funcionalidades y soporte, a continuación se instalarán los Codecs Multimedia para un buen funcionamiento y soporte pero para ello hay que añadir un repositorio de terceros llamado RPM Fusion ¿Quieres continuar? [y/n]"
    read -p ">> " opt
    case $opt in 
        y) 

            checkRPMfusion
            sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
            sudo dnf group install Multimedia
            sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
            sudo dnf update @sound-and-video
            sleep 3
            echo -e "\n${purple}[!] Instalando codecs para la Decodificacion de Video...${resetStyle}\n"
            sudo dnf install ffmpeg ffmpeg-libs libva libva-utils
            check_intel_or_amd
            echo -e "\n${purple}[!] Configurando OpenH264 para Firefox...${resetStyle}\n"
            sudo dnf config-manager --set-enabled fedora-cisco-openh264
            sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
            ;;
        n)
            ;;
    esac

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