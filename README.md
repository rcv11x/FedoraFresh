# FedoraFresh

FedoraFresh es un script escrito en Bash para automatizar el proceso de instalacion de drivers, programas... despues de instalar Fedora

⚠️ Solo ha sido probado en Fedora KDE v40, no esta terminado!

¿Que hace?

- Detecta si tienes un CPU intel o amd e instala los codecs necesarios para la aceleracion de hardware y decodificacion de video
- Detecta si tienes una GPU nvidia e instala los drivers propietarios (en caso de tener una AMD o Intel no hace nada ya que están incorporados en el kernel)
- Instala paquetes utiles, ver script: (packages)
- Instala configuraciones mias de zsh y kitty

iré actualizando esto, si tienes dudas puedes preguntarme por discord @rcv11x


## Uso

Primero asegurate de tener tu sistema actualizado:

`sudo dnf update --refresh`

Clona el repo: 

`git clone https://github.com/rcv11x/FedoraFresh; cd FedoraFresh`

Da permisos de ejecucion al script y ejecutalo:

`chmod +x install.sh`,<br>
`./install`
