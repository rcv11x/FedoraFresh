declare -A DNF_CATEGORIES=(
    [Herramientas/Esencial]="htop Monitor de recursos del sistema
curl Herramienta CLI para transferir datos y hacer peticiones
fastfetch Muestra información del sistema (Un Neofetch Mejorado)
vim Editor de texto avanzado
git Sistema de control de versiones
wget Herramienta CLI de descarga
ncdu Analizador de uso de disco
tmux Multiplexor de terminal
kitty Potente terminal acelerada por GPU
ranger Administrador de archivos en terminal
bat cat pero con esteroides mejorado y con resaltado de Sintaxis
lsd ls pero con esteroides mejorado y con resaltado de Sintaxis
yt-dlp Un descargador CLI de audio/vídeo de línea de comandos rico en funciones
unzip Soporte archivos comprimidos (extraer, comprimir...)
p7zip Soporte archivos comprimidos (extraer, comprimir...)
p7zip-plugins Soporte archivos comprimidos (extraer, comprimir...)
unrar Soporte archivos comprimidos (extraer, comprimir...)
lm_sensors Herramienta para monitorear temperaturas, voltaje, humedad y ventiladores
zsh Interprete de comandos ZSH
timeshift Crea copias de seguridad e instantaneas de tu sistema Linux"

    [Juegos]="steam Plataforma de juegos de Valve
mangohud Overlay Vulkan y OpenGL para ver FPS, Temperaturas... mientras juegas
goverlay Administra mangohud mediante una GUI
lutris Lutris - Gestor de juegos multiplataforma
nvtop Monitor y gestor de uso de GPU para Linux
wine Ejecutar aplicaciones de Windows"

    [Multimedia]="vlc Reproductor multimedia
yt-dlp Un descargador CLI de audio/vídeo de línea de comandos rico en funciones
kdenlive Editor de video
gimp Editor de imágenes
audacity Editor de audio"

    [VPN]="wireguard-tools VPN Wireguard
openvpn VPN OpenVPN"

    [Desarrollo]="vscode Editor de código de Microsoft
nodejs Entorno de ejecución de JavaScript
docker Plataforma de contenedores
python3 Lenguaje de programación Python
gcc Compilador de C/C++"

    [Ciberseguridad/Pentesting]="nmap Escaner de red
hashcat Recuperacion avanzada de contraseñas / cracking"
)

declare -A FLATPAK_CATEGORIES=(
    [Herramientas/Navegadores]="org.gnome.FileRoller Herramienta para comprimir y descomprimir archivos
org.mozilla.firefox Navegador Mozilla Firefox
com.google.Chrome Navegador Google Chrome
com.brave.Browser Navegador Brave (Internet rápido, IA, Adblock)
io.gitlab.librewolf-community Navegador LibreWolf (Seguridad de la privacidad y libertad del usuario)
org.torproject.torbrowser-launcher navegador Tor (Navega de forma privada y segura)
org.gnome.gedit Editor de texto
com.github.tchx84.Flatseal Flatseal (Administrar permisos de Flatpak)
org.qbittorrent.qBittorrent qBittorrent (Un cliente Bittorrent de código abierto)
com.bitwarden.desktop Bitwarden (Un gestor de contraseñas seguro y gratuito para todos tus dispositivos)"
    
    [Juegos]="com.valvesoftware.Steam Plataforma de juegos Steam
net.davidotek.pupgui2 ProtonUp-Qt (Instala y Administra diferentes versiones de Proton, Proton-GEy Wine)
com.github.Matoking.protontricks Protontricks (Aplicaciones y correcciones para juegos de Proton)
com.heroicgameslauncher.hgl Heroic Games Launcher (Lanzador de juegos de código abierto de Epic Games, GOG y Amazon Prime Games)
net.lutris.Lutris Lutris - Gestor de juegos multiplataforma
org.prismlauncher.PrismLauncher Prism Launcher (Lanzador personalizado para Minecraft)
com.obsproject.Studio OBS Studio (Transmisión en vivo y grabación de videos)"
    
    [Multimedia/Productividad]="fr.handbrake.ghb Handbrake (Video Transcoder)
org.videolan.VLC Reproductor multimedia VLC
org.kde.kdenlive Kdenlive - Editor de video
org.shotcut.Shotcut  Shotcut - Editor de Video
org.gimp.GIMP Crea imágenes y edita fotografías
org.audacityteam.Audacity Audacity - Editor de audio
org.kde.krita Krita (Dibuja y Pinta - Pintura Digital, Libertad Creativa)
org.blender.Blender Suite de creación 3D gratuita y de código abierto
com.github.unrud.VideoDownloader Video Downloader (Descargar vídeos de diferentes web)
com.obsproject.Studio OBS Studio (Transmisión en vivo y grabación de videos)
md.obsidian.Obsidian Obsidian (Notas, Base de conocimientos basada en Markdown)
com.bitwarden.desktop Bitwarden (Un gestor de contraseñas seguro y gratuito para todos tus dispositivos)
org.libreoffice.LibreOffice LibreOffice (Potente suite ofimática)
org.mozilla.Thunderbird Thunderbird (Cliente gratuito y de código abierto de correo electrónico, noticias, chat y calendario)"

    [Mensajeria]="com.discordapp.Discord Discord (Cliente de mensajería, voz y vídeo)
    dev.vencord.Vesktop Vesktop (Aplicación Discord de terceros más ágil y con mas funciones que la Oficial)
    org.telegram.desktop Telegram (Nueva era de la mensajería)
    org.signal.Signal Signal (Mensajeria privada)
    com.rtosta.zapzap ZapZap (Cliente de terceros para WhatsApp)
    org.mozilla.Thunderbird Thunderbird (Cliente gratuito y de código abierto de correo electrónico, noticias, chat y calendario)"
    
    [Desarrollo]="com.visualstudio.code Visual Studio Code
    com.visualstudio.code-oss Visual Studio Code de Codigo Abierto
org.gnome.Builder IDE de GNOME para desarrollo
org.codeblocks.codeblocks IDE Code::Blocks"

    [Emuladores]="net.rpcs3.RPCS3 Emulador/Debugger de PS3
net.pcsx2.PCSX2 Emulador de PS2
org.duckstation.DuckStation Emulador de PS1
org.ppsspp.PPSSPP Emulador de PSP
org.DolphinEmu.dolphin-emu Emulador de Wii/Gamecube
net.kuribo64.melonDS Emulador para Nintendo DS
io.github.lime3ds.Lime3DS Emulador de 3DS (Fork de Citra)
org.libretro.RetroArch Frontend para emuladores, motores de juegos y reproductores multimedia
info.cemu.Cemu Emulador de Nintendo Wii U
com.pokemmo.PokeMMO Emulador de juegos multijugador para Nintendo DS y GBA (Juega Pokemon Online)"

[Virtualizacion]="org.virt_manager.virt-manager Gestiona gráficamente KVM, Xen o LXC a través de libvirt
org.gnome.Boxes Virtualización simplificada (Crea maquinas virtuales de manera facil)
org.virt_manager.virt-viewer Acceso remoto a máquinas virtuales
org.tigervnc.vncviewer TigerVNC Viewer (Conéctese al servidor VNC y muestre el escritorio remoto)"
)
