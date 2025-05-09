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

# SCRIPT_DIR=$(pwd)
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

function msg_fail() {
    echo -e "\n${red}✗ FAIL${default}"
}

function press_any_key() {
    echo -e "\nPresiona una tecla para continuar"
    read -n 1 -s -r -p ""
}

function banner_text() {
    gum style --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 100 "$1" "$2" "$3"
}

# Blue
function info_banner_text() {
    gum style --foreground "#00dcff" --border double --margin "0 0" --padding "0 0" --align center --width 100 "$1" "$2"
}

# Yellow
function warn_banner_text() {
    gum style --foreground "#ffff00" --border double --margin "$1" --padding "$2" --align center --width 100 "$3" "$4"
}

# Red
function error_banner_text() {
    gum style --foreground "#ff0000" --border double --margin "$1" --padding "$2" --align center --width 100 "$3" "$4"
}


function speed_test() {

    echo -e "\n"
    if gum confirm "🌐 ¿Quieres realizar un test de velocidad para evaluar tu conexión a internet?"; then

        clear
        gum spin --spinner dot --title "Ejecutando test de velocidad..." -- bash -c "$SCRIPT_DIR/scripts/speedtest-cli --secure --simple 2>/dev/null > $SCRIPT_DIR/speedtest_output.txt"

        output=$(cat "$SCRIPT_DIR/speedtest_output.txt")
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
        warn_banner_text 0 0 "⚠ El paquete 'gum' no ha sido encontrado y es necesario para la ejecucion del script, a continuacion se va a instalar"
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

    mkdir -p "$SCRIPT_DIR/fonts/"

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

function detect_gpu() {

    # shellcheck disable=SC2317

    function install_amdgpu_top() {
        mkdir -p "$SCRIPT_DIR/tmp"
        echo -e "[!] Descargando e instalando amdgpu_top..."
        wget -nv "$amd_gputop_repo" -O "$SCRIPT_DIR/tmp/amdgpu_top.rpm"
        sudo dnf install -y "$SCRIPT_DIR/tmp/amdgpu_top.rpm"
        rm -rf "$SCRIPT_DIR/tmp"
        echo "Hola"
    }

    amd_gputop_repo=$(curl -s https://api.github.com/repos/Umio-Yasuno/amdgpu_top/releases \
  | jq -r '.[] | .assets[] | select(.name | endswith(".x86_64.rpm")) | .browser_download_url' \
  | head -n1)
    local intel_pkg_utils=("intel-gpu-tools" "nvtop")
    local amd_pkg_utils=("nvtop" "zsh" "lsd" "bat")

    banner_text "🔎 Detectando GPU instalada..."; sleep 1

    gpu_name=$(glxinfo -B | grep "Device:" | cut -d':' -f2- | sed 's/ (.*)//' | xargs)
    echo "- GPU detectada: $gpu_name"

    gpu_name_lower=$(echo "$gpu_name" | tr '[:upper:]' '[:lower:]')

    if [[ "$gpu_name_lower" == *intel* ]]; then
        echo -e "\n[!] Los drivers ya estan incorporados en el kernel y no es necesario instalar nada\n"

        echo -e "Paquetes recomendados: ${intel_pkg_utils[*]}\n"
        if gum confirm "¿Quieres instalar los paquetes recomendados para tu GPU Intel?"; then
            gum spin --spinner dot --title "▶️ Instalando paquetes..." -- \
            sudo dnf install "${intel_pkg_utils[*]}"
        else
            return 0
        fi

    elif [[ "$gpu_name_lower" == *amd* ]]; then
        echo -e "\n[!] Los drivers ya estan incorporados en el kernel y no es necesario instalar nada"

        echo -e "Paquetes recomendados: ${amd_pkg_utils[*]} y amdgpu_top\n"
        if gum confirm "¿Quieres instalar los paquetes recomendados para tu GPU AMD?"; then
            gum spin --spinner dot --title "▶️ Instalando paquetes..." -- \
            sudo dnf install "${amd_pkg_utils[*]}"
            echo -e "$(msg_ok) Paquetes instalados"
            gum spin --spinner dot --title "▶️ Instalando amdgpu_top..." -- install_amdgpu_top
            echo -e "$(msg_ok)"; sleep 1
        else
            return 0
        fi
    else
        echo -e "[!] No se ha encontrado una GPU compatible"
    fi
}

function view_system_info() {
    cpu_name=$(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{ print $2 }' | sed 's/^[ \t]*//')
    total_ram=$(awk '/MemTotal/ { printf "%.2f GB\n", $2 / 1024 / 1024 }' /proc/meminfo)
    gpu_info=$(lspci | grep -i 'vga\|3d\|2d' | awk -F': ' '{print $2}' | grep -v "3d" | sed 's/ (rev .*//')
    kernel_version=$(uname -r)
    banner_text "${yellow} --> Informacion del sistema <-- ${default}"
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

    if systemd-detect-virt --quiet; then
        echo -e "${yellow}[!] Se ha detectado un sistema virtualizado. Saltando actualización de firmware...${default}"l; sleep 1
        return 0
    fi

    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-devices
    sudo fwupdmgr get-updates
    sudo fwupdmgr update -y
}

function install_fonts() {
    sudo mkdir -p $fonts_dir

    gum spin --spinner dot --title "Descargando fuentes parcheadas..." -- bash -c "
        curl -sSL -o $SCRIPT_DIR/fonts/Iosevka.zip     \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*Iosevka.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $SCRIPT_DIR/fonts/IosevkaTerm.zip \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*IosevkaTerm.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $SCRIPT_DIR/fonts/ZedMono.zip      \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*ZedMono.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $SCRIPT_DIR/fonts/Meslo.zip        \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*Meslo.zip\"' | cut -d'\"' -f4)\"
        curl -sSL -o $SCRIPT_DIR/fonts/FiraCode.zip     \"\$(curl -s \"$iosevka_repo_url\" | grep -o '\"browser_download_url\": \"[^\"]*FiraCode.zip\"' | cut -d'\"' -f4)\"
    " && echo -e "$(msg_ok) Fuentes Descargadas"; sleep 2

    gum spin --spinner dot --title "Extrayendo fuentes en '$fonts_dir' ..." -- bash -c '
    for font in "'"$SCRIPT_DIR"'/fonts/"*.zip; do
        sudo unzip -o "$font" -d "'"$fonts_dir"'" >/dev/null
    done
    ' && echo -e "$(msg_ok) Fuentes extraídas."; sleep 2


    rm -rf "$SCRIPT_DIR/fonts"
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
            sudo cp -r "$SCRIPT_DIR/themes/grub/$theme_dir" /boot/grub2/themes/
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
    banner_text "${red} OPTIMIZACION Y LIMPIEZA DE LA DISTRO ${default}"
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
            "🎮 A continuacion se van instalar los controladores para que funcionen correctamente los mandos inalambricos de xbox entre otros como (S, Elites Series 2, 8BitDo...)"; sleep 1

    if ! gum confirm "¿Quieres proceder con la instalacion?"; then
        echo -e "\n ${red}✗ ${default}Cancelado, no se van a instalar los controladores xpadneo. Volviendo al menu principal..."; sleep 2
        clear
    else

        echo -e "ℹ️ Empezando instalacion...\n"; sleep 1.5

        local paquetes=("dkms" "make" "bluez" "bluez-tools" "kernel-devel-`uname -r`" "kernel-headers")

        for paquete in "${paquetes[@]}"; do
            if ! dnf list --installed "$paquete" &>/dev/null; then
                echo -e "${red}✗ ${default} No se ha encontrado el paquete ${paquete}. Instalando..."
                sudo dnf install -y "$paquete" &> /dev/null
                echo -e "${green}✓ ${default}Paquete ${paquete} instalado!"
            else
                echo -e "${green}✓ ${default}Paquete ${paquete} ya se encuentra instalado"
            fi
        done

        if dkms status | grep -q "xpadneo" && [[ -f "/opt/xpadneo/install.sh" ]]; then
            echo -e "${green}ℹ️ ${default}xpadneo ya se encuentra instalado en /opt/xpadneo\n"
            if gum confirm "¿Quieres buscar nuevas actualizaciones en el repositorio?"; then
                git config --global --ad safe.directory /opt/xpadneo
                cd /opt/xpadneo
                sudo git pull && sudo ./update.sh
                info_banner_text "xpadneo acaba de ser actualizado"
                echo -e "\nℹ️ Volviendo al menu principal..."; sleep 2
            else
                echo -e "\nℹ️ Volviendo al menu principal..."; sleep 2
            fi
        else
            echo -e "\nℹ️ ${red}✗ ${default}xpadneo no está correctamente instalado o falta el repositorio. Procediendo con la instalación...\n"; sleep 1
            sudo git clone https://github.com/atar-axis/xpadneo.git /opt/xpadneo
            cd /opt/xpadneo
            sudo ./install.sh
            info_banner_text "xpadneo acaba de ser instalado en /opt/xpadneo"; sleep 2
            clear
            cd "$SCRIPT_DIR" && menu
        fi

        sleep 2 && main
    fi
}


function install_nvidia_drivers() {

    check_rpm_fusion; clear
    nvidia_gpu_name=$(glxinfo -B | grep "Device:" | cut -d':' -f2- | sed 's/ (.*)//' | xargs)
    nvidia_gpu_name_lower=$(echo "$gpu_name" | tr '[:upper:]' '[:lower:]')
    
    local nvidia_pkgs=("akmod-nvidia" "xorg-x11-drv-nvidia-cuda")

    gum style \
            --foreground "#32CD32" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "⚠️ Importante" "Sigue esto solo si tienes una GPU NVIDIA. No sigas esto si tienes una GPU que ha dejado de ser compatible con las versiones de controladores más recientes, es decir, cualquier cosa anterior a las series nvidia GT / GTX 600, 700, 800, 900, 1000, 1600 y RTX 2000, 3000, 4000, 5000. Fedora viene preinstalado con controladores NOUVEAU que pueden o no funcionar mejor en las GPU más antiguas restantes. Esta guia pueden seguirla los usuarios de PC de escritorio y portátiles."; sleep 1

    echo -e "- GPU detectada: ${green}$nvidia_gpu_name${default}\n"

    if ! gum confirm "¿Quieres proceder con la instalacion?"; then
        echo -e "\n ${red}✗ ${default}Cancelado, no se van a instalar los controladores de ${green}nvidia${default}. Volviendo al menu principal..."; sleep 3
        clear
    else
        if rpm -q "${nvidia_pkgs[@]}" &> /dev/null; then
            if gum confirm "Parece que ya tienes los drivers de nvidia instalados ¿Es correcto?"; then
                echo -e "\n ${red}✗ ${default}Omitiendo... no se va a instalar nada. Volviendo al menu principal..."; sleep 2
                clear
                return 0
            fi
        fi

        info_banner_text "Instalando los controladores de nvidia"

        gum spin --spinner dot --title "Instalando paquetes de nvidia..." -- \
        sudo dnf install -y "${nvidia_pkgs[@]}" \
        || { msg_fail; echo "Error al instalar los drivers NVIDIA"; return 1; }

        gum spin --spinner line --title "Compilando y cargando módulo del kernel..." -- bash -c '
        until lsmod | grep -q "^nvidia"; do
            sleep 3
        done
    '

        whiptail --title "Instalación exitosa" --msgbox "Se han instalado correctamente los drivers propietarios para tu NVIDIA ${nvidia_gpu_name}.\n\n✔️ El módulo del kernel ya está cargado\n\nPara comprobarlo manualmente, ejecuta: 'modinfo -F version nvidia' en una nueva terminal\n\n¡Disfruta de tu sistema! - Ya puedes reiniciar." 14 80

        return 0
    fi
}

function install_rcv11x_config() {

        # -- CONFIGURACION -- #
        banner_text "Instalando plugins de ZSH para $USER y root..."
        mkdir -p "$HOME/.config/kitty"
        mkdir -p "$HOME/.icons"
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
        cp -rv "$SCRIPT_DIR/config/.zshrc" "$HOME"
        sudo rm -rf /root/.zshrc
        sudo ln -sfv ~/.zshrc /root/.zshrc
        banner_text "Copiando configuracion de Kitty y Nano..."; sleep 1

        cp -rv "$SCRIPT_DIR/config/kitty" "$HOME/.config"
        cp -rv "$SCRIPT_DIR/config/.nano" "$HOME"
        cp -rv "$SCRIPT_DIR/config/.nanorc" "$HOME"
        banner_text "Instalando y copiando config de Starship..."; sleep 1

        wget https://starship.rs/install.sh -O "$SCRIPT_DIR/install.sh" && chmod +x "$SCRIPT_DIR/install.sh" && sh "$SCRIPT_DIR/install.sh" -y
        cp -rv "$SCRIPT_DIR/config/starship.toml" "$HOME/.config"; sleep 1

        banner_text "Aplicando temas de mouse, wallpaper y otras configuraciones..."; sleep 1
        cp -rv "$SCRIPT_DIR/config/.icons/" "$HOME/.icons/"
        cp -rv "$SCRIPT_DIR/wallpapers/" "$pictures_dir"
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
        sudo dnf install -y "${essential_packages[@]}"

    echo -e "$(msg_ok) Paquetes: ${essential_packages[*]} instalados!"; sleep 1.5
}

# ------- HELP AND REPO ------- #

function show_help() {
  echo "Usage: ./fedorafresh.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help"
  echo "  -i, --install    Instalar el repo en el directorio $HOME/.fedorafresh para usarlo como un programa"
  echo "  -u, --update     Buscar actualizaciones y actualizar el repositorio"
 
  exit 0
}


function update_repo() {
    echo "🔄 Buscando actualizaciones de fedorafresh..."
    if [ -d "$SCRIPT_DIR/.git" ]; then
        cd "$SCRIPT_DIR" && git pull
        echo "✅ Repositorio actualizado."
        cd "$SCRIPT_DIR" || { echo "❌ Error: No se pudo acceder al directorio"; exit 1; }
    elif [ -d "$HOME/.fedorafresh/.git" ]; then
        cd "$HOME/.fedorafresh" && git pull
        echo "✅ Repositorio actualizado."
        cd - > /dev/null || { echo "❌ Error: No se pudo volver al directorio anterior"; exit 1; }
    else
        echo "❌ No se encontró el repositorio git,Por favor, instala fedorafresh con 'fedorafresh -i'"
    fi

    exit 0
}

function install_home_dir() {

    check_gum_installed

    if [[ -f "$HOME/.fedorafresh" && -f "$HOME/.fedorafresh/fedorafresh.sh" ]]; then         
        gum style \
            --foreground "#38b4ee" --border double --margin "1 2" --padding "1 2" --align center --width 80 \
            "ℹ️ FedoraFresh ya se encuentra instalado en '$HOME/.fedorafresh'"
        return 0         
    else
        git clone https://github.com/rcv11x/FedoraFresh.git "$HOME/.fedorafresh" && banner_text "✅ Se ha instalado FedoraFresh en '$HOME/.fedorafresh', Asegurate de añadir el alias de tu .bashrc o .zshrc para poder usar la herramienta desde cualquier ruta" "Copia y pega esto en tu shell: alias fedorafresh='$HOME/.fedorafresh/fedorafresh.sh' " || echo -e "❌ Ha ocurrido un error el instalar el repo, comprueba tu conexion a internet\n"
    fi

    press_any_key
}