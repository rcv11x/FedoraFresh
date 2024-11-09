#!/bin/bash

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "scripts/utils.sh"
source "scripts/packages.sh"

trap stop_script INT

function show_banner() {
                                                         
    echo -e "  _____        _                 _____              _      "
    echo -e " |  ___|__  __| | ___  _ __ __ _|  ___| __ ___  ___| |__   "
    echo -e " | |_ / _ \/ _' |/ _ \| '__/ _' | |_ | '__/ _ \/ __| '_ \  "
    echo -e " |  _|  __/ (_| | (_) | | | (_| |  _|| | |  __/\__ \ | | | "
    echo -e " |_|  \___|\__,_|\___/|_|  \__,_|_|  |_|  \___||___/_| |_| \n"
    echo -e "Hola! $(whoami) | Fedora: ${fedora_variant} v${fedora_version} \n\n" 

}

function menu() {

    echo -e "(1) ${cyan}Instalar FedoraFresh${default}"
    echo -e "(2) ${cyan}Instalar Flatpak's${default}"
    echo -e "(3) ${cyan}Aplicar temas GRUB${default}"
    echo -e "(4) ${cyan}Limpiar y Optimizar distro${default}"
    echo -e "(5) ${cyan}Instalar drivers para mandos Xbox${default}"
    echo -e "(i) ${cyan}Informacion del sistema${default}"
    echo -e "(0) ${cyan}Exit${default}\n"
}

function installation() {
    clear
    custom_banner_text "${yellow} A continuacion se va a ejecutar el script de instalacion ¿Seguro que quieres continuar? [yY/nN]${default}";
    read -r -p "fedorafresh >> " yesno
    if [[ $yesno == "n" || $yesno == "N" ]]; then
        clear
        main
    elif [[ $yesno == "y" || $yesno == "Y" ]]; then
        clear
        custom_banner_text "${yellow} EMPEZANDO INSTALACION ${default}\n"; sleep 2; clear
        
        sudo mkdir -pv /usr/local/share/fonts/custom
        mkdir -pv "$HOME/Imágenes/wallpapers/"
        mkdir -pv "$HOME/.icons"
        mkdir -pv "$HOME/.config/kitty"
        mkdir -pv "$current_dir/fonts/"
        dnf_hacks
        check_rpm_fusion
        install_multimedia
        install_flatpak
        echo -e "\n${purple}[!] Instalando paquetes...${default}\n"
        sudo dnf install -y "${dnf_packages[@]}"; sleep 1.5
        echo -e "$(msg_ok) Listo.\n"
        echo -e "\n${purple}[!] Instalando VS Code...${default}\n"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
        dnf check-update
        sudo dnf -y install code
        # sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge && sudo dnf update --refresh
        # sudo dnf install -y microsoft-edge-stable
        echo -e "$(msg_ok) Listo.\n"

        # -- CONFIGURACION -- #
        echo -e "\n${purple}[!] Instalando plugins para la ZSH...${default}\n"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; sleep 2
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        sudo chsh -s "$(which zsh)" "$USER"
        rm -rf "$HOME/.zshrc"
        cp -rv config/.zshrc "$HOME"
        cp -rv config/kitty/* "$HOME/.config/kitty"
        sleep 2
        install_fonts
        echo -e "\n${purple}[!] Aplicando temas de mouse, wallpaper y otras configuraciones...${default}\n"
        cp -rv config/.icons/* "$HOME/.icons/"
        cp -rv wallpapers/ "$HOME/Imágenes/"
        kwriteconfig6 --file "$HOME"/.config/kcminputrc --group Mouse --key cursorTheme "Bibata-Modern-Ice"
        plasma-apply-wallpaperimage "/home/$USER/Imágenes/wallpapers/1080p/203897-final.png"
        echo -e "\n${purple}[!] Estableciendo un nombre de HOST para la maquina ¿Que nombre le quieres poner? Ej. (mipc, pc-juan...)${default}\n"
        read -r -p "Hostname: " opcion
        sudo hostnamectl set-hostname "$opcion"
        install_gpu_drivers
        update_firmware
        
        if kdialog --title "Instalacion terminada" --yesno "Instalacion exitosa!\n\n Ahora espera de 5 a 10 minutos (en el caso de que tengas una gpu nvidia) ya que se estarán compilando los modulos del kernel, de lo contrario puedes reiniciar\n - El PC se reiniciará automaticamente en 5 minutos" \
           --yes-label "Reiniciar ahora" --no-label "Cancelar" 2> /dev/null; then
            sudo reboot now
        else
            sudo shutdown -r +5
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

            show_banner
            menu

            read -r -p "fedorafresh >> " opcion
            case $opcion in 
                1)
                    installation
                    ;;
                2)
                    clear
                    install_flatpaks
                    ;;
                3)
                    clear
                    apply_grub_themes
                    ;;
                4)
                    clear
                    optimization
                    ;;
                5)
                    clear
                    install_xbox_controllers
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

main