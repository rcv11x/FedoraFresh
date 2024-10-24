#!/bin/bash

source "../script.sh"

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
fedora_version=$(cat /etc/os-release | grep -i "VERSION_ID" | awk -F'=' '{print $2}')
fedora_variant=$(cat /etc/os-release | grep -w "VARIANT" | awk -F'=' '{print $2}' | sed 's/"//g')

function stop_script() {
    clear
    echo -e "\n${red}[!] Has salido del script \n${resetStyle}"
    exit 1
}

function msg_ok() {
    echo -e "${red}[${white} OK ${red}] ${resetStyle}\n"
}

function bannerText() {

    echo -e "=================================================================================="
    echo -e "=                                                                                 "
    echo -e "=   $1                                                                              " 
    echo -e "=                                                                                 "
    echo -e "=================================================================================="
}

function checkRPMfusion() {
    if [[ -f /etc/yum.repos.d/rpmfusion-free.repo || -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
        echo
        bannerText "${yellow}El repositorio de RPM Fusion ya se encuentra instalado.${resetStyle}"
        echo -e "$(msg_ok) Omitiendo...\n"
        sleep 5
    else
        echo
        bannerText "${yellow}Añadiendo el repositorio de RPM Fusion...${resetStyle}"
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm > /dev/null 2>&1
        echo -e "$(msg_ok) Listo\n"
        sleep 5
    fi
}

function check_intel_or_amd_cpu() {

    if grep -q "Intel" /proc/cpuinfo; then

        bannerText "${yellow}[!] CPU Intel detectado, instalando codecs necesarios...${resetStyle}"
        sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing

    elif grep -q "AMD" /proc/cpuinfo; then

        bannerText "${yellow}[!]CPU AMD detectado, instalando codecs necesarios...${resetStyle}"
        sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    else
        echo "${yellow}[Error]${resetStyle} CPU no reconocido"
        
    fi

}

function installMultimedia() {
    clear
    while true; do
        bannerText "Por defecto Fedora ${fedora_version} proporciona unicamente Codecs free que suelen carecer de muchas funcionalidades y soporte, a continuación se instalarán los Codecs Multimedia completos para un buen funcionamiento y soporte, para ello hay que añadir un repositorio de terceros llamado RPM Fusion ¿Quieres continuar? [y/n]"
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
                break
                ;;
                
            n)
                echo -e "\n${purple}[!] Omitiendo instalación de codecs multimedia.${resetStyle}\n"
                break
                ;;

            *)

                echo -e "\n${red}[!] Opción no válida, por favor elige [y/n]${resetStyle}"
                echo -e "\nPresiona una tecla para continuar"
                read -n 1 -s -r -p ""
                clear
                ;;
                
        esac
    done

}

# Detectar las GPU's instaladas en el sistema
gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | awk -F': ' '{print $2}')

echo "GPUs detectadas: "
echo "$gpu_info"

if echo "$gpu_info" | grep -i 'nvidia' > /dev/null; then
    echo "Se ha detectado una GPU NVIDIA."
    sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
fi

if echo "$gpu_info" | grep -i 'intel' > /dev/null; then
    echo "Se ha detectado una iGPU Intel."
    # 
fi