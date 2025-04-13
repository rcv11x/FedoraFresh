#!/bin/bash

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT


# -- Colors and Vars-- #

prompt=" fedorafresh >> "

default="\e[0m"
red="\e[0;31m"
blue="\e[0;34m"
cyan="\e[0;36m"
green="\e[0;32m"
yellow="\e[0;33m"
purple="\e[0;35m"
white="\e[0;37m"
black="\e[0;30m"

current_dir=$(pwd)
pictures_dir="$(xdg-user-dir PICTURES)"
fonts_dir=/usr/local/share/fonts/custom
fedora_version=$(cat /etc/os-release | grep -i "VERSION_ID" | awk -F'=' '{print $2}')
fedora_variant=$(cat /etc/os-release | grep -w "VARIANT" | awk -F'=' '{print $2}' | sed 's/"//g')
iosevka_repo_url="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
dnf_parallel_downloads=10


function stop_script() {
    clear
    echo -e "\n${red}⚠ Has salido del script \n${default}"
    exit 1
}

function msg_ok() {
    echo -e "\n${green}✓ OK${default}"
}

function press_any_key() {
    echo -e "\nPresiona una tecla para continuar"
    read -n 1 -s -r -p ""
}

function custom_banner_text() {
    gum style --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 "$1"
}


function speed_test() {

    echo -e "\n"
    if gum confirm "¿Quieres realizar un test de velocidad para evaluar tu conexión a internet?"; then

        clear
        gum spin --spinner dot --title "Ejecutando test de velocidad..." -- bash -c './scripts/speedtest-cli --secure --simple 2>/dev/null > speedtest_output.txt'

        output=$(<speedtest_output.txt)
        download=$(echo "$output" | grep "Download:" | awk '{print $2}')
        upload=$(echo "$output" | grep "Upload:" | awk '{print $2}')
        unit=$(echo "$output" | grep "Download:" | awk '{print $3}')

        gum style \
            --foreground 212 --border double --margin "1 2" --padding "1 2" --align center --width 50 \
            "Resultados del test de velocidad" \
            "⬇️  Descarga: $download $unit" \
            "⬆️  Subida: $upload $unit"

        if (( $(echo "$download >= 500" | bc -l) )); then
            echo -e "✅  Tienes una velocidad de descarga muy alta! Configuraré las descargas paralelas de DNF en 15 mas adelante.\n"
            dnf_parallel_downloads=15
        elif (( $(echo "$download >= 400" | bc -l) )); then
            echo -e "✅  Tienes una velocidad de descarga alta! Configuraré las descargas paralelas de DNF en 12 mas adelante.\n"
            dnf_parallel_downloads=12
        elif (( $(echo "$download >= 200" | bc -l) )); then
            echo -e "✅  Tienes una buena velocidad de descarga! Configuraré las descargas paralelas de DNF en 9 mas adelante.\n"
            dnf_parallel_downloads=9
        elif (( $(echo "$download >= 100" | bc -l) )); then
            echo -e "✅  Tienes una velocidad de descarga decente, Configuraré las descargas paralelas de DNF en 6 mas adelante.\n"
            dnf_parallel_downloads=6
        elif (( $(echo "$download <= 50" | bc -l) )); then
            echo -e "✅  Tienes una velocidad de descarga algo baja, Configuraré las descargas paralelas de DNF en 3 (por defecto) mas adelante.\n"
            dnf_parallel_downloads=3
        fi
    fi
}

function check_gum_installed() {

    if [[ -f /etc/yum.repos.d/charm.repo ]]; then          
        return 0         
    else
        echo -e "\n${yellow}⚠ 'gum' no ha sido encontrado y es necesario para la ejecucion del script, a continuacion se va a instalar\n\n${default}"
        press_any_key
        sudo tee /etc/yum.repos.d/charm.repo > /dev/null <<-EOF
[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key
EOF

        sudo rpm --import https://repo.charm.sh/yum/gpg.key && sudo dnf install -y gum &> /dev/null
    fi
}

function check_deps() {

    mkdir -p "$current_dir/fonts/"

    gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Checkeando dependencias...' && sleep 2

    local paquetes=("newt" "gum" "git")

    for paquete in "${paquetes[@]}"; do
        if ! dnf list --installed "$paquete" &>/dev/null; then
            echo -e "${red}✗ ${default} No se ha encontrado el paquete ${paquete}. Instalando..."
            sudo dnf install -y "$paquete" &> /dev/null
            echo -e "${green}✓ ${default}Paquete ${paquete} ya instalado!"
        else
            echo -e "${green}✓ ${default}Paquete ${paquete} ya se encuentra instalado!"
        fi
    done

    if ls /usr/local/share/fonts/custom/IosevkaTermNerdFont-*.ttf 1> /dev/null 2>&1; then
        echo -e "${green}✓ ${default}Fuentes parcheadas encontradas!"; sleep 1
    else
        echo -e "${red}✗ ${default}No se han encontrado las fuentes parcheadas necesarias"
        install_fonts
        echo -e "${green}✓ ${default}Fuentes instaladas!"; sleep 1
    fi

    if [ "$(mokutil --sb-state | awk '{print $2}')" = "enabled" ]; then
        echo -e "${yellow}⚠ ${default}Secure boot: habilitado${default}"; sleep 1
    else
        echo -e "${yellow}⚠ ${default}Secure boot: deshabilitado${default}"; sleep 1
    fi

    sleep 2
}

function check_rpm_fusion() {
    clear
    if [[ -f /etc/yum.repos.d/rpmfusion-free.repo || -f /etc/yum.repos.d/rpmfusion-nonfree.repo ]]; then
        echo
        gum style \
            --foreground "#ff0000" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "[!] El repositorio de RPM Fusion ya se encuentra instalado."
        echo -e "$(msg_ok) Omitiendo...\n"; sleep 1.5
    else
        echo
        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Añadiendo el repositorio de RPM Fusion..."
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm > /dev/null 2>&1
        sudo dnf group upgrade -y core
        sudo dnf4 group update -y core
        echo -e "$(msg_ok) Repositorio RPM instalado!\n"; sleep 1.5
        sleep 1.5
    fi
}

function check_cpu_type() {

    if grep -q "Intel" /proc/cpuinfo; then

        gum style \
            --foreground "#FFFF00" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "CPU Intel detectado, instalando codecs necesarios..."; sleep 1.5
        sudo dnf swap -y libva-intel-media-driver intel-media-driver --allowerasing

    elif grep -q "AMD" /proc/cpuinfo; then

        gum style \
            --foreground "#FFFF00" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "CPU AMD detectado, instalando codecs necesarios..."; sleep 1.5
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
        sudo dnf swap -y mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
        sudo dnf swap -y mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
    else
        gum style \
            --foreground "#ff0000" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "[Error] CPU no reconocido"; sleep 1.5
        
    fi
}

# Instalacion de Codecs Multimedia
function install_multimedia() {
    gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Instalando codecs multimedia completos para un buen funcionamiento y soporte..."; sleep 2
    check_rpm_fusion
    sudo dnf4 group upgrade -y multimedia
    sudo dnf swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
    # sudo dnf group install -y multimedia
    sudo dnf update -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    # sudo dnf install -y @sound-and-video
    sudo dnf group install -y sound-and-video
    # sudo dnf update -y @sound-and-video
    sleep 2
    gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Instalando codecs para la Decodificacion de Video..."; sleep 2
    sudo dnf install -y ffmpeg-libs libva libva-utils
    check_cpu_type
    gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Instalando y configurando OpenH264 para Firefox..."; sleep 2
    sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
    sudo dnf config-manager -y setopt fedora-cisco-openh264.enabled=1
    sudo rm -f /usr/lib64/firefox/browser/defaults/preferences/firefox-redhat-default-prefs.js
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
    echo -e "${white}- Distro: ${cyan}$XDG_CURRENT_DESKTOP $(plasmashell --version 2>/dev/null | awk '{print $2}') ($XDG_SESSION_TYPE) ${default}"
    echo -e "${white}- Secure boot: ${cyan}$(mokutil --sb-state | awk '{print $2}') ${default}"
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
    sudo mkdir -p $fonts_dir

    gum spin --spinner dot --title "Descargando fuentes parcheadas..." -- bash -c "
        curl -sSL -o $current_dir/fonts/Iosevka.zip     \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*Iosevka.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $current_dir/fonts/IosevkaTerm.zip \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*IosevkaTerm.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $current_dir/fonts/ZedMono.zip      \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*ZedMono.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $current_dir/fonts/Meslo.zip        \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*Meslo.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $current_dir/fonts/FiraCode.zip     \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*FiraCode.zip\"' | cut -d'\"' -f4)\"
    " && echo -e "$(msg_ok) Fuentes Descargadas"; sleep 2

    gum spin --spinner dot --title "Extrayendo fuentes en '$fonts_dir' ..." -- bash -c '
    for font in "'"$current_dir"'/fonts/"*.zip; do
        sudo unzip -o "$font" -d "'"$fonts_dir"'" >/dev/null
    done
    ' && echo -e "$(msg_ok) Fuentes extraídas."; sleep 2


    rm -rf "$current_dir/fonts"
    sudo rm /usr/local/share/fonts/custom/*.md /usr/local/share/fonts/custom/*.txt
    sudo fc-cache &> /dev/null
}

function install_flatpak() {
    gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Instalando Repositorio de Flatpak..."; sleep 1
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo -e "$(msg_ok) Repositorio flatpak instalado!."; sleep 2
}

function dnf_hacks() {
    gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "Optimizando el gestor de paquetes dnf para una mayor velocidad..."; sleep 2
    echo "max_parallel_downloads=$dnf_parallel_downloads" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
}

function apply_grub_themes() {
    clear
    current_theme=$(grep '^GRUB_THEME=' /etc/default/grub | cut -d'"' -f2)
    if [[ -n $current_theme ]]; then
        theme_name=$(basename "$(dirname "$current_theme")")
        gum style --foreground 212 "Tema actual: $theme_name"
    else
        gum style --foreground 212 "Tema actual: Ninguno"
    fi

    gum style --border normal --margin "1 0" --padding "1 2" --border-foreground 61 "Selecciona un tema para administrar (no se instalará automáticamente):"

    selected_theme=$(gum choose "bsol (Pantalla azul de Windows)" "oldbios (Estilo BIOS antiguas)" "Volver al menú principal")

    case $selected_theme in
        "bsol (Pantalla azul de Windows)")
            theme_dir="bsol"
            theme_name="bsol"
            ;;
        "oldbios (Estilo BIOS antiguas)")
            theme_dir="OldBIOS"
            theme_name="OldBIOS"
            ;;
        "Volver al menú principal")
            main
            return
            ;;
    esac

    clear
    gum style --foreground 44 "Tema seleccionado: $theme_name"
    action=$(gum choose "Instalar" "Eliminar" "Volver")

    case $action in
        "Instalar")
            echo "Instalando tema..."
            sudo cp -r "themes/grub/$theme_dir" /boot/grub2/themes/
            if grep -q '^GRUB_THEME=' /etc/default/grub; then
                gum confirm "Ya hay un tema configurado en GRUB: ¿Deseas reemplazarlo?" && \
                sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"/boot/grub2/themes/$theme_name/theme.txt\"|" /etc/default/grub || {
                    gum style --foreground 212 "Manteniendo el tema existente."
                    return
                }
            else
                echo "GRUB_THEME=\"/boot/grub2/themes/$theme_name/theme.txt\"" | sudo tee -a /etc/default/grub
            fi
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            gum style --foreground 42 "✅ Tema $theme_name instalado correctamente."
            ;;

        "Eliminar")
            echo "Eliminando tema..."
            sudo rm -rf "/boot/grub2/themes/$theme_name"
            sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            gum style --foreground 160 "🗑️ Tema $theme_name eliminado."
            ;;

        "Volver")
            apply_grub_themes
            ;;
    esac
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

    gum style \
            --foreground "#32CD32" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "A continuacion se van instalar los controladores para que funcionen correctamente los mandos inalambricos de xbox entre otros como (S, Elites Series 2, 8BitDo...)"; sleep 2
    
    local paquetes=("dkms" "make" "bluez" "bluez-tools" "kernel-devel-`uname -r`" "kernel-headers")

    for paquete in "${paquetes[@]}"; do
        if ! dnf list --installed "$paquete" &>/dev/null; then
            echo -e "${red}✗ ${default} No se ha encontrado el paquete ${paquete}. Instalando..."
            sudo dnf install -y "$paquete" &> /dev/null
            echo -e "${green}✓ ${default}Paquete ${paquete} instalado!"
        else
            echo -e "${green}✓ ${default}Paquete ${paquete} ya está instalado."
        fi
    done

    if dkms status | grep -q "xpadneo" && [[ -f "/opt/xpadneo/install.sh" ]]; then
        if gum confirm "✓ xpadneo ya está instalado y el repositorio se encuentra en /opt/xpadneo. ¿Quieres buscar nuevas actualizaciones?\n"; then
            git config --global --ad safe.directory /opt/xpadneo
            cd /opt/xpadneo
            sudo git pull && sudo ./update.sh
        else
            echo -e "\nVolviendo al menu principal..."; sleep 2
        fi
    else
        echo "✗ xpadneo no está correctamente instalado o falta el repositorio. Procediendo con la instalación..."
        sudo git clone https://github.com/atar-axis/xpadneo.git /opt/xpadneo
        cd /opt/xpadneo
        sudo ./install.sh
        cd "$current_dir" && menu
    fi

    sleep 2 && main
}

function install_rcv11x_config() {

        # -- CONFIGURACION -- #
        custom_banner_text "Instalando plugins de ZSH para $USER y root..."
        sudo dnf install kitty zsh -y
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
        sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        sudo git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        sudo chsh -s "$(which zsh)" "$USER"
        sudo chsh -s "$(which zsh)" root
        rm -rf "$HOME/.zshrc"
        cp -rv config/.zshrc "$HOME"
        sudo rm -rf /root/.zshrc
        sudo ln -sfv ~/.zshrc /root/.zshrc
        custom_banner_text "Copiando configuracion de Kitty y Nano..."; sleep 1
        cp -rv config/kitty/* "$HOME/.config/kitty"
        cp -rv config/.nano "$HOME"
        cp -rv config/.nanorc "$HOME"
        custom_banner_text "Instalando y copiando config de Starship..."; sleep 1
        wget https://starship.rs/install.sh && chmod +x install.sh
        sh install.sh -y
        cp -rv config/starship.toml "$HOME/.config"
        sleep 2
        custom_banner_text "Aplicando temas de mouse, wallpaper y otras configuraciones..."; sleep 1
        cp -rv config/.icons/* "$HOME/.icons/"
        cp -rv wallpapers/ "$HOME/Imágenes/"
        kwriteconfig6 --file "$HOME"/.config/kcminputrc --group Mouse --key cursorTheme "Bibata-Modern-Ice"
        plasma-apply-wallpaperimage "/home/$USER/Imágenes/wallpapers/4k/250345-final.png"
        
        {
            echo
            echo "[services][kitty.desktop]"
            echo "_launch=Meta+Return"
        } >> "$HOME/.config/kglobalshortcutsrc"
}

function install_essential_packages(){

    local essential_packages=("htop" "zsh" "lsd" "bat")

    gum style \
            --foreground "#ff0000" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "A continuacion se van a instalar paquetes esenciales"; sleep 2

    gum spin --spinner dot --title "Instalando paquetes..." -- \
        sudo dnf install -y "${essential_packages[@]}" &> /dev/null

    echo -e "$(msg_ok) Paquetes: ${essential_packages[*]} instalados!"; sleep 1.5
}

# ------- HELP AND REPO ------- #

function show_help() {
  echo "Usage: ./fedorafresh.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help"
  echo "  -i, --install    Instalar el repo en el directorio HOME"
  echo "  -u, --update     Buscar actualizaciones y actualizar el repositorio"
 
  exit 0
}

function update_repo() {
  echo "🔄 Buscando actualizaciones..."
  git pull
  echo "✅ Repositorio actualizado."
  exit 0
}

function install_home_dir() {

    if [[ -f "$HOME/.fedorafresh" && -f "$HOME/.fedorafresh/fedorafresh.sh" ]]; then         
        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "ℹ️ FedoraFresh ya se encuentra instalado en '$HOME/.fedorafresh'"
        return 0         
    else
        git clone https://github.com/rcv11x/FedoraFresh.git "$HOME/.fedorafresh"
        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "\n✅ Se ha instalado FedoraFresh en '$HOME/.fedorafresh'"
    fi
}