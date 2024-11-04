# FedoraFresh

FedoraFresh es un script escrito en Bash para automatizar el proceso de instalacion de drivers, programas, configuraciones.. despues de instalar Fedora

⚠️ Este script esta hecho unicamente para Fedora KDE plasma

¿Que hace?

- Modifica y mejora dnf5 (el nuevo gestor de paquetes de fedora) para una mayor velocidad
- Habilita el repositorio RPMFusion y Flatpak
- Detecta si tienes un CPU intel o amd e instala los codecs necesarios para la aceleracion de hardware y decodificacion de video
- Detecta si tienes una GPU nvidia e instala los drivers propietarios (en caso de tener una AMD o Intel no hace nada ya que están incorporados en el kernel)
- Instala paquetes utiles personales (mios), ver script: (packages) para modificar alguno a tu antojo
- Descarga e instala fuentes para la terminal y el sistema
- Instala configuraciones (mias) de zsh, kitty... 

Iré actualizando y mejorando el script con el tiempo, si tienes dudas puedes preguntarme por discord @rcv11x


## Uso
### 1.

Primero asegurate de tener tu sistema actualizado:

`sudo dnf update --refresh`

y Reinicia el sistema

### 2.

Clona el repo: 

`git clone https://github.com/rcv11x/FedoraFresh`<br>

Entra

`cd FedoraFresh`

Asigna permisos de ejecucion al script y ejecutalo:

`chmod +x install.sh`<br>
`./install`
