#!/bin/bash

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "../fedorafresh.sh"

# -- Colors and Vars-- #

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
current_dir=$(pwd)
iosevka_repo_url="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"


function stop_script() {
    clear
    echo -e "\n${red}[!] Has salido del script \n${resetStyle}"
    exit 1
}

function msg_ok() {
    echo -e "\n${red}[${white} OK! ${red}] ${resetStyle}\n"
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

function check_rpm_fusion() {
    if [[ -f /etc/yum.repos.d/rpmfusion-free.repo || -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
        echo
        echo -e "${red}[!] El repositorio de RPM Fusion ya se encuentra instalado.${resetStyle}\n"
        echo -e "$(msg_ok) Omitiendo...\n"
        sleep 1.5
    else
        echo
        custom_banner_text "${yellow}Añadiendo el repositorio de RPM Fusion...${resetStyle}"
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm > /dev/null 2>&1
        sudo dnf group update -y core
        echo -e "$(msg_ok) Listo.\n"
        sleep 1.5
    fi
}

function check_cpu_type() {

    if grep -q "Intel" /proc/cpuinfo; then

        custom_banner_text "${yellow}[!] CPU Intel detectado, instalando codecs necesarios...${resetStyle}"
        sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing

    elif grep -q "AMD" /proc/cpuinfo; then

        custom_banner_text "${yellow}[!]CPU AMD detectado, instalando codecs necesarios...${resetStyle}"
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
    else
        echo "${yellow}[Error]${resetStyle} CPU no reconocido"
        
    fi
}

# Instalacion de Codecs Multimedia
function install_multimedia() {
    custom_banner_text "${yellow}Instalando codecs multimedia completos para un buen funcionamiento y soporte${resetStyle}"; sleep 2
    check_rpm_fusion
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    # sudo dnf group install -y Multimedia
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf install -y sound-and-video
    sudo dnf update -y @sound-and-video
    sleep 2
    echo -e "\n${purple}[!] Instalando codecs para la Decodificacion de Video...${resetStyle}\n"
    sudo dnf -y install ffmpeg ffmpeg-libs libva libva-utils
    check_cpu_type
    echo -e "\n${purple}[!] Instalando y configurando OpenH264 para Firefox...${resetStyle}\n"
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
                echo -e "\n${purple}[!] Se ha detectado una GPU NVIDIA en el sistema. Instalando drivers propietarios...${resetStyle}\n"
                sleep 2
                sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda || {
                    echo -e "${red}[!] Error al instalar los drivers de NVIDIA.${resetStyle}\n"
                    return 1
                }
                ;;
            *amd*)
                echo -e "\n${purple}[!] Se ha detectado una GPU AMD en el sistema.${resetStyle}\n"
                echo -e "${purple}[!] - Omitiendo... ya que los drivers están incorporados en el kernel.${resetStyle}\n"
                sleep 2
                ;;
            *intel*)
                echo -e "\n${purple}[!] Se ha detectado una GPU Intel en el sistema.${resetStyle}\n"
                echo -e "${purple}[!] - Omitiendo... ya que los drivers están incorporados en el kernel.${resetStyle}\n"
                sleep 2
                echo -e "\n${purple}[!] Instalando algunas herramientas útiles para Intel...${resetStyle}\n"
                sudo dnf install -y intel-gpu-tools || {
                    echo -e "${red}[!] Error al instalar las herramientas para Intel.${resetStyle}\n"
                    return 1
                }
                ;;
            *)
                echo -e "${yellow}[!] No se detectó una GPU compatible.${resetStyle}\n"
                ;;
        esac
    done <<< "$gpu_info"
}

function view_system_info() {
    cpu_name=$(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{ print $2 }' | sed 's/^[ \t]*//')
    total_ram=$(awk '/MemTotal/ { printf "%.2f GB\n", $2 / 1024 / 1024 }' /proc/meminfo)
    gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | awk -F': ' '{print $2}' | grep -v "3d" | sed 's/ (rev .*//')
    kernel_version=$(uname -r)
    custom_banner_text "${yellow} --> Informacion del sistema <-- ${resetStyle}"
    echo -e "\n${white}- CPU: ${cyan}$cpu_name ${resetStyle}"
    echo -e "${white}- RAM: ${cyan}$total_ram ${resetStyle}"
    echo -e "${white}- GPU: ${cyan}$gpu_info ${resetStyle}"
    echo -e "${white}- Kernel Version: ${cyan}$kernel_version ${resetStyle}"
    echo -e "${white}- Distro: ${cyan}$XDG_CURRENT_DESKTOP $(plasmashell --version | awk '{print $2}') ($XDG_SESSION_TYPE) ${resetStyle}"
    press_any_key
    clear
}

function update_firmware() {
    echo -e "${purple}[!] Buscando actualizaciones de firmware...${resetStyle}"; sleep 1
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-devices
    sudo fwupdmgr get-updates
    sudo fwupdmgr update
}

function install_fonts() {
    echo -e "\n${purple}[!] Descargando e instalando fuentes parcheadas...${resetStyle}\n"; sleep 1.5
    curl -sSL -o ./fonts/Iosevka.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*Iosevka.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/IosevkaTerm.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*IosevkaTerm.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/ZedMono.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*ZedMono.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/Meslo.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*Meslo.zip"' | cut -d'"' -f4)"
    curl -sSL -o ./fonts/FiraCode.zip "$(curl -s "$iosevka_repo_url" | grep -o '"browser_download_url": "[^"]*FiraCode.zip"' | cut -d'"' -f4)"

    for font in *.zip; do
        echo -e "${red}[!] Descomprimiendo fuentes en '/usr/local/share/fonts/custom' ...${resetStyle}"; sleep 1
        sudo unzip -o "./fonts/$font" -d /usr/local/share/fonts/custom
        echo -e "$(msg_ok) Listo.\n"
    done

    rm -rf ./fonts
    sudo rm /usr/local/share/fonts/custom/*.md /usr/local/share/fonts/custom/*.txt
    sudo fc-cache -v
}

function install_flatpak() {
    echo -e "${purple}[!] Instalando Repositorio de Flatpak...${resetStyle}"; sleep 1.5
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo -e "$(msg_ok) Listo.\n"
}

function dnf_hacks() {
    echo -e "\n${purple}[!] Configurando DNF...${resetStyle}\n"; sleep 1.5
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
    echo "max_parallel_downloads=20" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
}

function apply_grub_themes() {
    clear
    current_theme=$(grep '^GRUB_THEME=' /etc/default/grub | cut -d'"' -f2)
    if [[ -n $current_theme ]]; then
        theme_name=$(basename "$(dirname "$current_theme")") # Extrae el nombre de la carpeta del tema
        echo -e "${yellow}Tema actual: ${theme_name}${resetStyle}"
    else
        echo -e "${yellow}Tema actual: Ninguno${resetStyle}"
    fi

    echo -e "\n${purple}A continuacion se muestran los temas disponibles para instalar con este script, al seleccionar uno no se te instalara directamente, primero te mostrara opciones como 'instalarlo' o 'eliminarlo'. ${resetStyle}\n"
    echo -e "(1) ${cyan}bsol (Pantalla azul de la muerte de windows)${resetStyle}"
    echo -e "(2) ${cyan}oldbios (Estilo las BIOS antiguas)${resetStyle}"
    echo -e "(m) ${cyan}Volver al menu principal${resetStyle}"


    echo -e "\n¿Cual quieres modificar?"

    while true; do

        read -r -p "fedora(theme) >> " opt
        case $opt in 
            1)
                clear
                echo -e "${cyan}Tema seleccionado: bsol - Acciónes: instalar(i) | Eliminar(d) | Volver: (r) ${resetStyle}\n"
                echo -e "${cyan}Instalar${resetStyle}"
                echo -e "${cyan}Eliminar${resetStyle}"
                read -r -p "fedorafresh(theme) >> " opt
                if [[ $opt == "i" ]]; then
                    echo -e "${cyan}Instalando tema...${resetStyle}"; sleep 1
                    sudo cp -r themes/grub/bsol /boot/grub2/themes/

                    if grep -q '^GRUB_THEME=' /etc/default/grub; then
                        echo -e "${red}¡Advertencia! Ya hay un tema configurado en GRUB: ${theme_name}.${resetStyle}"
                        read -r -p "¿Deseas reemplazar el tema existente? (s/n): " replace

                        if [[ $replace == "s" ]]; then
                            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/bsol/theme.txt"|' /etc/default/grub
                        else
                            echo -e "${cyan}Manteniendo el tema existente.${resetStyle}"
                            return
                        fi
                else
                    echo 'GRUB_THEME="/boot/grub2/themes/bsol/theme.txt"' | sudo tee -a /etc/default/grub
                fi

                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                echo -e "\n${cyan}--> Tema bsol instalado <-- $(msg_ok)${resetStyle}"

                elif [[ $opt  == "d" ]]; then
                    echo -e "${cyan}Eliminando tema...${resetStyle}"
                    sudo rm -rf /boot/grub2/themes/bsol
                    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
                    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                    echo -e "\n${cyan}--> Tema bsol eliminado <--$(msg_ok)${resetStyle}"; sleep 2
                elif [[ $opt  == "r" ]]; then
                    apply_grub_themes
                fi
                ;;
            2)
                clear
                echo -e "${cyan}Tema seleccionado: OldBIOS - Acciónes: instalar(i) | Eliminar(d) | Volver: (r) ${resetStyle}\n"
                echo -e "${cyan}Instalar${resetStyle}"
                echo -e "${cyan}Eliminar${resetStyle}"
                read -r -p "fedorafresh(theme) >> " opt
                if [[ $opt == "i" ]]; then
                    echo -e "${cyan}Instalando tema...${resetStyle}"; sleep 1
                    sudo cp -r themes/grub/OldBIOS/ /boot/grub2/themes/

                    if grep -q '^GRUB_THEME=' /etc/default/grub; then
                        echo -e "${red}¡Advertencia! Ya hay un tema configurado en GRUB_THEME.${resetStyle}"
                        read -r -p "¿Deseas reemplazar el tema existente? (s/n): " replace

                        if [[ $replace == "s" ]]; then
                            sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/OldBIOS/theme.txt"|' /etc/default/grub
                        else
                            echo -e "${cyan}Manteniendo el tema existente.${resetStyle}"
                            return
                        fi
                else
                    echo 'GRUB_THEME="/boot/grub2/themes/OldBIOS/theme.txt"' | sudo tee -a /etc/default/grub
                fi
                    
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                echo -e "\n${cyan}--> Tema OldBIOS instalado <--$(msg_ok)${resetStyle}"

                elif [[ $opt  == "d" ]]; then
                    echo -e "${cyan}Eliminando tema...${resetStyle}"
                    sudo rm -rf /boot/grub2/themes/OldBIOS/
                    sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
                    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                    echo -e "\n${cyan}--> Tema OldBIOS eliminado <--$(msg_ok)${resetStyle}"; sleep 2
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
                echo -e "\n${red}[!] Opción no válida${resetStyle}"
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
    custom_banner_text "${red} OPTIMIZACION Y LIMPIEZA DE LA DISTRO ${resetStyle}"
    echo -e "\n- Se le hará alguna pregunta y tendrá que responder con y/N ¿Continuar?\n"
    read -r -p "fedorafresh(optimization) >> " opt
    opt=${opt:-N}
    if [[ "$opt" =~ ^[Yy]$ ]]; then
        clear
        echo -e "${red}[!] A continuación se van a buscar paquetes huérfanos que ya no son necesarios en el sistema. Asegúrate de que los quieres borrar y presiona y/N más abajo para continuar\n${resetStyle}"
        sleep 3
        
        packages_to_remove=$(sudo dnf autoremove --assumeno | tail -n +3)

        if [[ -z "$packages_to_remove" ]]; then
            echo "$(msg_ok) No hay paquetes huérfanos para eliminar."
            press_any_key
        else
            echo -e "\n${yellow}[!] Se eliminarán los siguientes paquetes:${resetStyle}\n$packages_to_remove\n${resetStyle}"
            
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
        echo -e "${yellow}Eliminando cache de miniaturas y archivos temporales...${resetStyle}"; sleep 1.5
        user_cache_size=$(du -hs ~/.cache/ | awk '{print $1}')
        rm -rf ~/.cache/*
        echo "$(msg_ok) Se han eliminado todos los archivos temporales y cache de miniaturas del usuario $USER - Se han limpiado $user_cache_size"
        echo -e "${red}[!] Con el paso del tiempo y el uso del sistema se volverá a llenar la cache poco a poco${resetStyle}"
        press_any_key

        clear
        varlog_size=$(du -hs /var/log 2> /dev/null | awk '{print $1}')
        echo -e "${yellow}He detectado que su carpeta /var/log (donde se almacenan los logs del sistema) tiene un tamaño de $varlog_size ¿Quiere eliminar los logs de las ultimas 2 semanas? presiona y/N ${resetStyle}"
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