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

![](https://i.imgur.com/CHRrqyg.png)

## Uso
### 1.

Primero asegurate de tener tu sistema actualizado:

`sudo dnf update --refresh`

y Reinicia el sistema

### 2.

Clona el repo: 

`git clone https://github.com/rcv11x/FedoraFresh`<br>

Entra a la carpeta clonada y asigna los permisos necesarios de ejecucion al script:

`cd FedoraFresh && chmod +x fedorafresh.sh`

Ejecuta el script mediante: 

`./fedorafresh`


# Guia del script

## Opcion 1 (Instalacion)

La opcion 1 es la de la instalacion del script, si acabas de instalar Fedora con KDE por primera vez asegurate de tener el sistema actualizado mediante el comando `sudo dnf update -y`, si tienes todo actualizado puedes ejecutar el script, en caso contrario reinicia el sistema para aplicar la actualizacion y despues ejecuta la opcion 1 de nuevo<br><br>
Esta opcion instalará todo lo necesario para empezar a usar fedora por primera vez pero es bueno combinarlo con la opcion 2 ⬇️

## Opcion 2 (Instalar Flatpaks)

Opcion muy util para instalar una gran lista de paquetes flatpak, esta es una lista que he añadido personalmente y puedes agregar/quitar paquetes a tu gusto, simplemente puedes editar el archivo `scripts/flatpak_pkgs.sh` y una vez hayas echo algun cambio lo guardas y ejecutas el script `./fedorafresh.sh` de nuevo  con la opcion 2

Nota: tambien puedes editar el archivo `scripts/dnf_pkgs.sh` para agregar/quitar paquetes dnf que no son flatpaks antes de ejecutar el script de instalacion, aunque los que he agregado yo ya son suficientes y es recomendable dejarlo como está.

## Opcion 3 (Temas GRUB)

Opcion util si te interesa cambiar el tema de tu GRUB de forma sencilla, de momento hay 2 Temas pero iré agregando mas con el tiempo

## Opcion 4 (Optimizar Ditro)

Ya sabemos que linux no es como windows que suele llenarse mas de archivos temporales y basura con el tiempo, pero en linux tambien pasa y aunque es menos frecuente si llevas usando ya un tiempo tu PC esta opcion te resultará util ya que te quitará bastante espacio de tu disco duro

## Opcion 5 (Controladores mandos Xbox)

Opcion muy util si tienes mandos de xbox ya sea de 360, one, one x/s o incluso mandos inalambricos bluetooh ya que instalará varios paquetes para que tengas un buen soporte y compatibilidad para tus mandos