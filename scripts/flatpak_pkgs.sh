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

function install_flatpaks() {

    echo -e "\n${purple}[!] Instalando paquetes flatpak...${default}\n"; sleep 2

    flatpak_packages=(
        org.prismlauncher.PrismLauncher # --> Launcher de Minecraft
        # com.spotify.Client # --> Cliente de Spotify
        com.github.wwmm.easyeffects # --> Efectos de audio y equalizador para pipewire
        com.visualstudio.code # --> Editor de codigo Visual Studio Code
        dev.zed.Zed # --> Editor de codigo Zed
        # org.gimp.GIMP # --> Editor de fotos GIMP
        com.obsproject.Studio # --> OBS Studio (grabar video y transmision)
        org.telegram.desktop # --> Telegram
        net.lutris.Lutris # --> Cliente para jugar juegos de Epic Games, GOG, EA App
        com.heroicgameslauncher.hgl # --> Cliente para jugar juegos de Epic Games, GOG y Amazon Prime Games
        dev.vencord.Vesktop # --> Cliente de discord de terceros con muchas mejoras (transmision de pantalla, mejor audio...)
        org.qbittorrent.qBittorrent # --> Cliente torrent de codigo abierto
        org.videolan.VLC # --> Reproductor de video y audio
        md.obsidian.Obsidian # --> Editor y notas en Markdown
        de.leopoldluley.Clapgrep # --> Interfaz de usuario facil para grep (buscar archivos en el sistema)
        dev.bragefuglseth.Keypunch # --> Practicar mecanografia
        com.github.tchx84.Flatseal # --> Administrador de permisos de Flatpak 
        io.gitlab.theevilskeleton.Upscaler # --> Mejora imagenes a una resolucion mayor o menor
        com.github.unrud.VideoDownloader # --> Descarga videos de youtube o otra web de forma facil
        com.usebottles.bottles # --> Administracion de wine, ejecutar facilmente juegos y aplicaciones windows
        net.davidotek.pupgui2 # --> Administrador de versiones de proton
        # -- Emuladores -- #
        net.rpcs3.RPCS3 # --> Emulador de PS3
        org.DolphinEmu.dolphin-emu # --> Emulador de Wii y Gamecube
        # net.kuribo64.melonDS # --> Emulador de Nintendo DS
        org.ppsspp.PPSSPP # --> Emulador de PSP
        net.pcsx2.PCSX2 # --> Emulador de PS2
)

    for package in "${flatpak_packages[@]}"; do
        flatpak install flathub -y "$package"
    done

    custom_banner_text "${yellow} Se han instalado todos los paquetes flatpak ${default}"
    press_any_key
    clear
}

