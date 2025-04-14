#!/usr/bin/bash

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/install_dnf_packages.sh"
source "$SCRIPT_DIR/scripts/install_flatpak_packages.sh"
source "$SCRIPT_DIR/scripts/packages_list.sh"

trap stop_script INT

function show_banner() {
                                                         
    echo -e "  _____        _                 _____              _      "
    echo -e " |  ___|__  __| | ___  _ __ __ _|  ___| __ ___  ___| |__   "
    echo -e " | |_ / _ \/ _' |/ _ \| '__/ _' | |_ | '__/ _ \/ __| '_ \  "
    echo -e " |  _|  __/ (_| | (_) | | | (_| |  _|| | |  __/\__ \ | | | "
    echo -e " |_|  \___|\__,_|\___/|_|  \__,_|_|  |_|  \___||___/_| |_| \n"
    echo -e "Hola $(whoami)! | Fedora: ${fedora_variant} v${fedora_version}"
    echo -e "Estas en: ${yellow}$SCRIPT_DIR${default}\n\n" 

}

function menu() {

    echo -e "[1] ${cyan}Instalar FedoraFresh${default}"
    echo -e "[2] ${cyan}Instalar/Desintalar paquetes Fedora${default}"
    echo -e "[3] ${cyan}Instalar/Desinstalar paquetes Flatpak${default}"
    echo -e "[4] ${cyan}Aplicar temas GRUB${default}"
    echo -e "[5] ${cyan}Limpiar y Optimizar distro${default}"
    echo -e "[6] ${cyan}Instalar drivers para mandos Xbox${default}"
    echo -e "[7] ${cyan}Instalar config de rcv11x${default}"
    echo -e "[i] ${cyan}Informacion del sistema${default}"
    echo -e "[0] ${cyan}Exit${default}\n"
}

function installation() {
    clear
    check_deps
    speed_test
    
    if ! gum confirm "¿Quieres empezar con la instalacion de FedoraFresh?"; then
        clear
        main
    else
        clear
        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 50 \
            "EMPEZANDO INSTALACION..."; sleep 2


        sudo mkdir -p $fonts_dir
        mkdir -p "${pictures_dir}/wallpapers/"
        mkdir -p "$HOME/.icons"
        mkdir -p "$HOME/.config/kitty"
        mkdir -p "$SCRIPT_DIR/fonts/"

        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Establece un nombre de host para tu equipo Ej. (mipc, pc-juan...)" "⚠️ Ten cuidado con los espacios y caracteres raros"
        hostname_name=$(gum input --placeholder="Nombre de tu equipo... " --cursor.mode="blink")
        sudo hostnamectl set-hostname "$hostname_name"

        dnf_hacks
        check_rpm_fusion
        install_multimedia
        install_flatpak
        install_gpu_drivers
        update_firmware
        install_essential_packages
        
        if kdialog --title "Instalacion terminada" --yesno "Instalacion exitosa!, puedes cancelar para volver al script o reiniciar el PC" \
           --yes-label "Reiniciar ahora" --no-label "Cancelar" 2> /dev/null; then
            sudo reboot now
        else
            clear
        fi
    fi
       
}

function main(){
    clear
    if [[ $(id -u) = 0 || $(whoami) = "root" ]]; then
        echo -e "\n${red}[!] Ejecuta el script sin permisos de sudo\n${default}"
        exit 1
    else
        while true; do

            check_gum_installed
            show_banner
            menu

            read -r -p "${prompt}" opcion
            case $opcion in 
                1)
                    installation
                    ;;
                2)
                    clear
                    install_dnf_packages
                    ;;
                3)
                    clear
                    install_flatpak_packages
                    ;;

                4)
                    clear
                    apply_grub_themes
                    ;;
                5)
                    clear
                    optimization
                    ;;
                6)
                    clear
                    install_xbox_controllers
                    ;;
                7)
                    clear
                    install_rcv11x_config
                    ;;
                i)
                    clear
                    view_system_info
                    ;;
                0)
                    exit 0
                    ;;
                *) 
                    echo -e "\n${red}[!] Opción no válida${default}"
                    press_any_key
                    clear
                    ;;
            esac
        done
    fi
    
}
case "$1" in
  -h|--help)
    show_help
    ;;
  -i|--install)
    install_home_dir
    ;;
  -u|--update)
    update_repo
    ;;
   "" )
    main
    ;;
  *)
    echo "❌ Parametro no valido o no existe: $1"
    echo "Usa --help para ver los parametros disponibles."
    exit 1
    ;;
esac

main

