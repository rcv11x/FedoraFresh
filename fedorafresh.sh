#!/bin/bash

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

    echo -e "(1) ${cyan}Instalar FedoraFresh${resetStyle}"
    echo -e "(2) ${cyan}Instalar Flatpak's${resetStyle}"
    echo -e "(3) ${cyan}Aplicar temas GRUB${resetStyle}"
    echo -e "(4) ${cyan}Limpiar y Optimizar distro${resetStyle}"
    echo -e "(i) ${cyan}Informacion del sistema${resetStyle}"
    echo -e "(0) ${cyan}Exit${resetStyle}\n"
}

function installation() {
    clear
    custom_banner_text "${yellow} A continuacion se va a ejecutar el script de instalacion ¿Seguro que quieres continuar? [yY/nN]${resetStyle}";
    read -r -p "fedorafresh >> " yesno
    if [[ $yesno == "n" || $yesno == "N" ]]; then
        clear
        main
    elif [[ $yesno == "y" || $yesno == "Y" ]]; then
        clear
        custom_banner_text "${yellow} EMPEZANDO INSTALACION ${resetStyle}\n"; sleep 2; clear
        
        sudo mkdir -pv /usr/local/share/fonts/custom
        mkdir -pv "$HOME/Imágenes/wallpapers/"
        mkdir -pv "$HOME/.icons"
        mkdir -pv "$HOME/.config/kitty"
        mkdir -pv "$current_dir/fonts/"
        dnf_hacks
        check_rpm_fusion
        install_multimedia
        install_flatpak
        echo -e "\n${purple}[!] Instalando paquetes...${resetStyle}\n"
        sudo dnf install -y "${dnf_packages[@]}"; sleep 1.5
        echo -e "$(msg_ok) Listo.\n"
        echo -e "\n${purple}[!] Instalando VS Code...${resetStyle}\n"
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
        dnf check-update
        sudo dnf -y install code
        # sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge && sudo dnf update --refresh
        # sudo dnf install -y microsoft-edge-stable
        echo -e "$(msg_ok) Listo.\n"

        # -- CONFIGURACION -- #
        echo -e "\n${purple}[!] Instalando plugins para la ZSH...${resetStyle}\n"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; sleep 2
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        sudo chsh -s "$(which zsh)" "$USER"
        rm -rf "$HOME/.zshrc"
        cp -rv config/.zshrc "$HOME"
        cp -rv config/kitty/* "$HOME/.config/kitty"
        sleep 2
        install_fonts
        echo -e "\n${purple}[!] Aplicando temas de mouse, wallpaper y otras configuraciones...${resetStyle}\n"
        cp -rv config/.icons/* "$HOME/.icons/"
        cp -rv wallpapers/ "$HOME/Imágenes/"
        kwriteconfig6 --file "$HOME"/.config/kcminputrc --group Mouse --key cursorTheme "Bibata-Modern-Ice"
        # kwriteconfig6 --file kglobalshortcutsrc --group "services" --key "_launch[kitty.desktop]" "Meta+Return"
        # kwriteconfig6 --file kglobalshortcutsrc --group "services" --key "_launch[org.kde.konsole.desktop]" "none"
        # kwriteconfig6 --file kglobalshortcutsrc --group "services" --key "_launch[org.kde.dolphin.desktop]" "Meta+F"
        # kwriteconfig6 --file kglobalshortcutsrc --group "services" --key "ActiveWindowScreenShot[org.kde.spectacle.desktop]" "Meta+Print\tAlt+1"
        # kwriteconfig6 --file kglobalshortcutsrc --group "services" --key "RectangularRegionScreenShot[org.kde.spectacle.desktop]" "Meta+Shift+Print\tAlt+3"
        # kwriteconfig6 --file ~/.config/kcminputrc --group Mouse --key PointerAccelerationProfile "0"
        # kwriteconfig6 --file ~/.config/kwinrc --group Plugins --key shakecursorEnabled false
        plasma-apply-wallpaperimage "/home/$USER/Imágenes/wallpapers/1080p/wallhaven-l81qoy_1920x1080.png"
        echo -e "\n${purple}[!] Estableciendo un nombre de HOST para la maquina ¿Que nombre le quieres poner? Ej. (mipc, pc-juan...)${resetStyle}\n"
        read -r -p "Hostname: " opcion
        sudo hostnamectl set-hostname "$opcion"
        install_gpu_drivers
        update_firmware
        custom_banner_text "\n${purple}--> Instalacion exitosa!, ahora espera de 5 a 10 minutos (en el caso de que tengas una gpu nvidia) ya que se estarán compilando los modulos del kernel, de lo contrario puedes reiniciar\n - El PC se reiniciará automaticamente en 5 minutos <--${resetStyle}\n"
        shutdown -r +5
    fi
       
}

function main(){
    clear
    if [[ $(id -u) = 0 || $(whoami) = "root" ]]; then
        echo -e "\n${red}[!] Ejecuta el script sin sudo\n${resetStyle}"
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
                i)
                    clear
                    view_system_info
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

main