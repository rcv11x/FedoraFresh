#!/bin/bash

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "../fedorafresh.sh"

# -- Colors and Vars-- #

default="\e[0m"
red="\e[0;31m"
blue="\e[0;34m"
cyan="\e[0;36m"
green="\e[0;32m"
yellow="\e[0;33m"
purple="\e[0;35m"
white="\e[0;37m"
black="\e[0;30m"
prompt=" fedorafresh >> "

fedora_version=$(cat /etc/os-release | grep -i "VERSION_ID" | awk -F'=' '{print $2}')
fedora_variant=$(cat /etc/os-release | grep -w "VARIANT" | awk -F'=' '{print $2}' | sed 's/"//g')
current_dir=$(pwd)
iosevka_repo_url="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"


function stop_script() {
    clear
    echo -e "\n${red}⚠ Has salido del script \n${default}"
    exit 1
}

function msg_ok() {
    echo -e "\n${green}✓ OK${default}\n"
}

function press_any_key() {
    echo -e "\nPresiona una tecla para continuar"
    read -n 1 -s -r -p ""
}

function custom_banner_text() {
    echo -e "============================================================================================================"
    echo -e "=                                                                                                           "
    echo -e "=   $1                                                                                                      " 
    echo -e "=                                                                                                           "
    echo -e "============================================================================================================"
}

function check_deps() {

    if ls /usr/local/share/fonts/custom/IosevkaTermNerdFont-*.ttf 1> /dev/null 2>&1; then
        echo -e "\n${green}✓ ${default}Fuentes parcheadas encontradas!"; sleep 1
    else
        echo -e "\n${red}✗ ${default} No se ha encontrado las fuentes parcheadas. Instalandolas...\n"
        curl -sSL -o ./fonts/IosevkaTerm.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*IosevkaTerm.zip"' | cut -d'"' -f4)" 2> /dev/null
        sudo unzip -o "./fonts/$font" -d /usr/local/share/fonts/custom
        rm -rf ./fonts
        echo -e "\n${green}✓ ${default}Fuentes instaladas!"; sleep 1
    fi

    if [ "$(mokutil --sb-state | awk '{print $2}')" = "enabled" ]; then
        echo -e "${yellow} ⚠ ${default}Secure boot habilitado${default}"; sleep 1
    else
        echo -e "${yellow} ⚠ ${default}Secure boot deshabilitado${default}"; sleep 1
    fi

    ./fedorafresh.sh
}

function check_rpm_fusion() {
    if [[ -f /etc/yum.repos.d/rpmfusion-free.repo || -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
        echo
        echo -e "${red}[!] El repositorio de RPM Fusion ya se encuentra instalado.${default}\n"
        echo -e "$(msg_ok) Omitiendo...\n"
        sleep 1.5
    else
        echo
        custom_banner_text "${yellow}Añadiendo el repositorio de RPM Fusion...${default}"
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm > /dev/null 2>&1
        sudo dnf check-update
        sudo dnf group upgrade -y core
        msg_ok
        sleep 1.5
    fi
}

function check_cpu_type() {

    if grep -q "Intel" /proc/cpuinfo; then

        custom_banner_text "${yellow}[!] CPU Intel detectado, instalando codecs necesarios...${default}"
        sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing

    elif grep -q "AMD" /proc/cpuinfo; then

        custom_banner_text "${yellow}[!]CPU AMD detectado, instalando codecs necesarios...${default}"
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    else
        echo "${yellow}[Error]${default} CPU no reconocido"
        
    fi
}

# Instalacion de Codecs Multimedia
function install_multimedia() {
    custom_banner_text "${yellow}Instalando codecs multimedia completos para un buen funcionamiento y soporte${default}"; sleep 2
    check_rpm_fusion
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    sudo dnf group install -y multimedia
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf install -y @sound-and-video
    sudo dnf update -y @sound-and-video
    sleep 2
    echo -e "\n${purple}[!] Instalando codecs para la Decodificacion de Video...${default}\n"
    sudo dnf -y install ffmpeg ffmpeg-libs libva libva-utils
    check_cpu_type
    echo -e "\n${purple}[!] Instalando y configurando OpenH264 para Firefox...${default}\n"
    # sudo dnf config-manager --set-enabled fedora-cisco-openh264
    sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
}

function install_gpu_drivers() {
    gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | awk -F': ' '{print $2}' | grep -v "3d" | sed 's/ (rev .*//')

    echo "GPUs detectadas:";
    while read -r gpu_name; do
        echo "- $gpu_name"; sleep 1
    done <<< "$gpu_info"

    while read -r gpu_name; do
        case "$gpu_name" in
            *nvidia*)
                echo -e "\n${purple}[!] Se ha detectado una GPU NVIDIA en el sistema. Instalando drivers propietarios...${default}\n"
                sleep 2
                sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver || {
                    echo -e "${red}[!] Error al instalar los drivers de NVIDIA.${default}\n"
                    return 1
                }
                ;;
            *amd*)
                echo -e "\n${purple}[!] Se ha detectado una GPU AMD en el sistema.${default}\n"
                echo -e "${purple}[!] - Omitiendo... ya que los drivers están incorporados en el kernel.${default}\n"
                sleep 2
                ;;
            *intel*)
                echo -e "\n${purple}[!] Se ha detectado una GPU Intel en el sistema.${default}\n"
                echo -e "${purple}[!] - Omitiendo... ya que los drivers están incorporados en el kernel.${default}\n"
                sleep 2
                echo -e "\n${purple}[!] Instalando algunas herramientas útiles para Intel...${default}\n"
                sudo dnf install -y intel-gpu-tools || {
                    echo -e "${red}[!] Error al instalar las herramientas para Intel.${default}\n"
                    return 1
                }
                ;;
            *)
                echo -e "${yellow}[!] No se detectó una GPU compatible.${default}\n"
                ;;
        esac
    done <<< "$gpu_info"
}

function view_system_info() {
    cpu_name=$(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{ print $2 }' | sed 's/^[ \t]*//')
    total_ram=$(awk '/MemTotal/ { printf "%.2f GB\n", $2 / 1024 / 1024 }' /proc/meminfo)
    gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | awk -F': ' '{print $2}' | grep -v "3d" | sed 's/ (rev .*//')
    kernel_version=$(uname -r)
    custom_banner_text "${yellow} --> Informacion del sistema <-- ${default}"
    echo -e "\n${white}- CPU: ${cyan}$cpu_name ${default}"
    echo -e "${white}- RAM: ${cyan}$total_ram ${default}"
    echo -e "${white}- GPU: ${cyan}$gpu_info ${default}"
    echo -e "${white}- Kernel Version: ${cyan}$kernel_version ${default}"
    echo -e "${white}- Distro: ${cyan}$XDG_CURRENT_DESKTOP $(plasmashell --version | awk '{print $2}') ($XDG_SESSION_TYPE) ${default}"
    echo -e "${white}- Secure boot: ${cyan}$(mokutil --sb-state | awk '{print $2}')"
    press_any_key
    clear
}

function update_firmware() {
    echo -e "${purple}[!] Buscando actualizaciones de firmware disponibles...${default}"; sleep 1
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-devices
    sudo fwupdmgr get-updates
    sudo fwupdmgr update
}

function install_fonts() {
    echo -e "\n${purple}[!] Descargando e instalando fuentes parcheadas...${default}\n"; sleep 1.5
    curl -sSL -o ./fonts/Iosevka.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*Iosevka.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/IosevkaTerm.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*IosevkaTerm.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/ZedMono.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*ZedMono.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/Meslo.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*Meslo.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/FiraCode.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*FiraCode.zip"' | cut -d'"' -f4)"

    for font in *.zip; do
        echo -e "${red}[!] Descomprimiendo fuentes en '/usr/local/share/fonts/custom' ...${default}"; sleep 1
        sudo unzip -o "./fonts/$font" -d /usr/local/share/fonts/custom
        echo -e "$(msg_ok) Listo.\n"
    done

    rm -rf ./fonts
    sudo rm /usr/local/share/fonts/custom/*.md /usr/local/share/fonts/custom/*.txt
    sudo fc-cache -v
}

function install_flatpak() {
    echo -e "${purple}[!] Instalando Repositorio de Flatpak...${default}"; sleep 1.5
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    msg_ok
}

function dnf_hacks() {
    echo -e "\n${purple}[!] Configurando DNF...${default}\n"; sleep 1.5
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
}

function apply_grub_themes() {
    clear
    current_theme=$(grep '^GRUB_THEME=' /etc/default/grub | cut -d'"' -f2)
    if [[ -n $current_theme ]]; then
        theme_name=$(basename "$(dirname "$current_theme")") # Extrae el nombre de la carpeta del tema
        echo -e "${yellow}Tema actual: ${theme_name}${default}"
    else
        echo -e "${yellow}Tema actual: Ninguno${default}"
    fi

    echo -e "\n${purple}A continuacion se muestran los temas disponibles para instalar con este script, al seleccionar uno no se te instalara directamente, primero te mostrara opciones como 'instalarlo' o 'eliminarlo'. ${default}\n"
    echo -e "(1) ${cyan}bsol (Pantalla azul de la muerte de windows)${default}"
    echo -e "(2) ${cyan}oldbios (Estilo las BIOS antiguas)${default}"
    echo -e "(m) ${cyan}Volver al menu principal${default}"


    echo -e "\n¿Cual quieres modificar?"

    while true; do

        read -r -p "${prompt}" opt
        case $opt in 
            1)
                clear
                echo -e "${cyan}Tema seleccionado: bsol - Acciónes: instalar(i) | Eliminar(d) | Volver: (r) ${default}\n"
                echo -e "${cyan}Instalar${default}"
                echo -e "${cyan}Eliminar${default}"
                read -r -p "${prompt}" opt
                if [[ $opt == "i" ]]; then
                    echo -e "${cyan}Instalando tema...${default}"; sleep 1
                    sudo cp -r themes/grub/bsol /boot/grub2/themes/

                    if grep -q '^GRUB_THEME=' /etc/default/grub; then
                        echo -e "${red}¡Advertencia! Ya hay un tema configurado en GRUB: ${theme_name}.${default}"
                        read -r -p "¿Deseas reemplazar el tema existente? (s/n): " replace

                        if [[ $replace == "s" ]]; then
                            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/bsol/theme.txt"|' /etc/default/grub
                        else
                            echo -e "${cyan}Manteniendo el tema existente.${default}"
                            return
                        fi
                else
                    echo 'GRUB_THEME="/boot/grub2/themes/bsol/theme.txt"' | sudo tee -a /etc/default/grub
                fi

                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                echo -e "\n${cyan}--> Tema bsol instalado <-- $(msg_ok)${default}"

                elif [[ $opt  == "d" ]]; then
                    echo -e "${cyan}Eliminando tema...${default}"
                    sudo rm -rf /boot/grub2/themes/bsol
                    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
                    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                    echo -e "\n${cyan}--> Tema bsol eliminado <--$(msg_ok)${default}"; sleep 2
                elif [[ $opt  == "r" ]]; then
                    apply_grub_themes
                fi
                ;;
            2)
                clear
                echo -e "${cyan}Tema seleccionado: OldBIOS - Acciónes: instalar(i) | Eliminar(d) | Volver: (r) ${default}\n"
                echo -e "${cyan}Instalar${default}"
                echo -e "${cyan}Eliminar${default}"
                read -r -p "${prompt}" opt
                if [[ $opt == "i" ]]; then
                    echo -e "${cyan}Instalando tema...${default}"; sleep 1
                    sudo cp -r themes/grub/OldBIOS/ /boot/grub2/themes/

                    if grep -q '^GRUB_THEME=' /etc/default/grub; then
                        echo -e "${red}¡Advertencia! Ya hay un tema configurado en GRUB_THEME.${default}"
                        read -r -p "¿Deseas reemplazar el tema existente? (s/n): " replace

                        if [[ $replace == "s" ]]; then
                            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/OldBIOS/theme.txt"|' /etc/default/grub
                        else
                            echo -e "${cyan}Manteniendo el tema existente.${default}"
                            return
                        fi
                else
                    echo 'GRUB_THEME="/boot/grub2/themes/OldBIOS/theme.txt"' | sudo tee -a /etc/default/grub
                fi
                    
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                echo -e "\n${cyan}--> Tema OldBIOS instalado <--$(msg_ok)${default}"

                elif [[ $opt  == "d" ]]; then
                    echo -e "${cyan}Eliminando tema...${default}"
                    sudo rm -rf /boot/grub2/themes/OldBIOS/
                    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
                    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                    echo -e "\n${cyan}--> Tema OldBIOS eliminado <--$(msg_ok)${default}"; sleep 2
                elif [[ $opt  == "r" ]]; then
                    apply_grub_themes
                fi
                ;;
            m)  
                main
                ;;
            0)
                exit 0
                ;;
            *) 
                echo -e "\n${red}[!] Opción no válida${default}"
                echo -e "\nPresiona una tecla para continuar"
                read -n 1 -s -r -p ""
                clear
                apply_grub_themes
                ;;
        esac
    done
}

function optimization() {

    clear
    custom_banner_text "${red} OPTIMIZACION Y LIMPIEZA DE LA DISTRO ${default}"
    echo -e "\n- Se le hará alguna pregunta y tendrá que responder con y/N ¿Continuar?\n"
    read -r -p "${prompt}" opt
    opt=${opt:-N}
    if [[ "$opt" =~ ^[Yy]$ ]]; then
        clear
        echo -e "${red}[!] A continuación se van a buscar paquetes huérfanos que ya no son necesarios en el sistema. Asegúrate de que los quieres borrar y presiona y/N más abajo para continuar\n${default}"
        sleep 3
        
        packages_to_remove=$(sudo dnf autoremove --assumeno | tail -n +3)

        if [[ -z "$packages_to_remove" ]]; then
            echo "$(msg_ok) No hay paquetes huérfanos para eliminar."
            press_any_key
        else
            echo -e "\n${yellow}[!] Se eliminarán los siguientes paquetes:${default}\n$packages_to_remove\n${default}"
            
            read -r -p "¿Deseas continuar con la eliminación? (y/N): " confirm
            confirm=${confirm:-N}
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                sudo dnf autoremove -y
                echo "Paquetes eliminados."
            else
                echo "Eliminación cancelada."
            fi
        fi

        clear
        echo -e "${yellow}Eliminando cache de miniaturas y archivos temporales...${default}"; sleep 1.5
        user_cache_size=$(du -hs ~/.cache/ | awk '{print $1}')
        rm -rf ~/.cache/*
        echo "$(msg_ok) Se han eliminado todos los archivos temporales y cache de miniaturas del usuario $USER - Se han limpiado $user_cache_size"
        echo -e "${red}[!] Con el paso del tiempo y el uso del sistema se volverá a llenar la cache poco a poco${default}"
        press_any_key

        clear
        varlog_size=$(du -hs /var/log 2> /dev/null | awk '{print $1}')
        echo -e "${yellow}He detectado que su carpeta /var/log (donde se almacenan los logs del sistema) tiene un tamaño de $varlog_size ¿Quiere eliminar los logs de las ultimas 2 semanas? presiona y/N ${default}"
        sleep 1.5
        
        read -r -p "¿Desea continuar con la eliminación de logs? (y/N): " confirm
        confirm=${confirm:-N}
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            sudo journalctl --vacuum-time=2weeks
            echo "$(msg_ok) Se han eliminado todos los logs de las últimas 2 semanas."
        else
            echo "[!] Eliminación de logs cancelada."
        fi
        
        press_any_key
        clear
    else 
        main
    fi
}

function install_xbox_controllers() {

    echo -e "${yellow} A continuacion se van instalar los controladores necesarios para que funcionen correctamente los mandos de Xbox (360, One, One X/S) tanto cableados como por bluetooth\n\n${default}- [!] Para ello es importante tener en cuenta que si tienes habilitado el Secure Boot (Modo seguro) es posible que no se instalen correctamente los drivers para los mandos inalambricos ya que no estan firmados ¿Quieres continuar y empezar la instalacion? [yY/nN]\n${default}";
    read -r -p "${prompt}" yesno
    if [[ $yesno == "n" || $yesno == "N" ]]; then
        clear
        main
    elif [[ $yesno == "y" || $yesno == "Y" ]]; then
        if [ "$(mokutil --sb-state | awk '{print $2}')" = "enabled" ]; then
            echo -e "${yellow} Se ha detectado que tienes secure boot habilitado, por lo tanto xpadneo (Controlador para el gamepad inalámbrico de Xbox One) no funcionará ya que no está firmado.${default}"
            press_any_key
        else
            if [[ -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:sentry:xone.repo || -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:sentry:xpadneo.repo ]]; then
                if dnf list --installed | grep -q "xone" && dnf list --installed | grep -q "xone"; then 
                    clear
                    echo -e "[!] Se han encontrado los drivers de xone y xpadneo instalados en el sistema. Omitiendo... \n$(msg_ok)"; sleep 5
                    main
                fi
            else
                echo -e "${yellow} Instalando los drivers xone y xpadneo para los controladores de Xbox...${default}"; sleep 2
                echo -e "\nCheckeando dependencias...\n"; sleep 1.5
                dnf list --installed | grep -q "lpf"

                if [[ "$?" -ne 0 ]]; then 
                    echo "✗ No se ha encontrado el paquete 'lpf' - instalandolo..."
                    sudo dnf install -y lpf 2> /dev/null
                fi
                
                sudo dnf copr enable -y sentry/xpadneo
                sudo dnf install -y xpadneo
                sudo dnf copr enable -y sentry/xone
                sudo dnf install -y xone lpf-xone-firmware
                echo -e "${yellow} A continuacion se van a firmar, construir y instalar los modulos de xone (Necesario para los mandos de Xbox One y Xbox Series X|S). Si se le hace alguna pregunta debe responder todo con 'y'${default}"
                press_any_key
                echo -e "${cyan}Aprobando licencia y verificando requisitos del firmware...${default}"
                sudo lpf approve xone-firmware
                msg_ok
                echo -e "${cyan}Descargando y construyendo el firmware.....${default}"
                sudo lpf build xone-firmware
                msg_ok
                echo -e "${cyan}Instalando el firmware en el sistema...${default}"
                sudo lpf install xone-firmware
                msg_ok
                if kdialog --yesno "Se acaban de instalar exitosamente los controladores para los mandos de Xbox, ahora debes reiniciar el PC para que se cargen los modulos." \
            --yes-label "Reiniciar ahora" --no-label "Cancelar" 2> /dev/null; then
                    sudo reboot now
                else
                    main
                fi
            fi
        fi
    else
        main 
    fi

}