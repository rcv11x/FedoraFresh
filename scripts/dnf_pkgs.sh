#!/bin/bash 

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "../scripts/utils.sh"

############################################################################################################
#
#  Si hay algun paquete de ambas listas que no le interesa simplemente comentelo con una amoadila '#'
#
#  [!] también puede agregar mas paquetes si lo desea
############################################################################################################

dnf_packages=(
        # Esenciales
        vim
        git
        curl
        wget
        htop
        btop
        fastfetch
        lm_sensors
        kitty
        zsh
        lsd
        bat
        timeshift
        wine
        kdenlive
        krita
        yt-dlp
        # Programas y utilidades para juegos #
        steam
        mangohud
        goverlay
        nvtop
        # Soporte archivos comprimidos (extraer, comprimir...)
        unzip
        p7zip
        p7zip-plugins
        unrar
        thunderbird
        # VPN
        wireguard-tools
        # openvpn

    )
