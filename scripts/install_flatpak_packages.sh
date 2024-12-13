#!/bin/bash 

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "../scripts/utils.sh"

function show_categories_flatpak() {

    local sorted_categories=($(for category in "${!FLATPAK_CATEGORIES[@]}"; do echo "$category"; done | sort))

    local MENU_ITEMS=()
    for category in "${sorted_categories[@]}"; do
        MENU_ITEMS+=("$category" "Paquetes de $category")
    done


    local SELECTED_CATEGORY=$(whiptail --title "Instala/Desinstala paquetes Flatpak" \
        --menu "Elige una categoría:" 20 100 10 \
        "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

    # Salir si el usuario cancela
    if [ $? -ne 0 ] || [ -z "$SELECTED_CATEGORY" ]; then
        main
        exit 0
    fi

    show_options_flatpak "$SELECTED_CATEGORY"
}

function show_options_flatpak() {
    local category="$1"
    
    local CHOSEN_OPTION=$(whiptail --title "Instalador de Paquetes - $category" \
        --menu "Selecciona una opción:" 20 60 10 \
        "1" "Instalar paquetes" \
        "2" "Desinstalar paquetes" 3>&1 1>&2 2>&3)

    # Salir si el usuario cancela
    if [ $? -ne 0 ] || [ -z "$CHOSEN_OPTION" ]; then
        main
        exit 0
    fi

    if [ "$CHOSEN_OPTION" == "1" ]; then
        show_packages_flatpak "Instalar" "$category"
    else
        show_packages_flatpak "Desinstalar" "$category"
    fi
}

function show_packages_flatpak() {
    local action="$1"
    local category="$2"
    local action_verb=""
    local action_title=""

    # Verifica si la categoría es válida
    if [ -z "${FLATPAK_CATEGORIES[$category]}" ]; then
        echo "Categoría inválida o no seleccionada. Saliendo..."
        exit 1
    fi

    local PACKAGES=()

    while read -r package descripcion; do
        # Verifica si el paquete está instalado
        if flatpak list --app | grep -q "$package"; then
            STATUS="[INSTALADO]"
        else
            STATUS="[NO INSTALADO]"
        fi

        if [ "$action" == "Instalar" ] && [ "$STATUS" == "[NO INSTALADO]" ]; then
            PACKAGES+=("$package" "$descripcion" OFF)
        elif [ "$action" == "Desinstalar" ] && [ "$STATUS" == "[INSTALADO]" ]; then
            PACKAGES+=("$package" "$descripcion $STATUS" OFF)
        fi
    done <<< "${FLATPAK_CATEGORIES[$category]}"

    local SELECTION=$(whiptail --title "Instalador de Paquetes - $category" \
        --checklist "Selecciona los paquetes a $action:" 20 120 10 \
        "${PACKAGES[@]}" 3>&1 1>&2 2>&3)

    # Sale si el usuario selecciona cancelar
    if [ $? -ne 0 ]; then
        main
        exit 0
    fi

    # Convertir selección a array
    local PACKAGES_TO_MANAGE=($(echo $SELECTION | tr -d '"'))

    if [ ${#PACKAGES_TO_MANAGE[@]} -gt 0 ]; then
        if [ "$action" == "Instalar" ]; then
            action_verb="instalados"
            action_title="Instalación"
            echo "Instalando paquetes: ${PACKAGES_TO_MANAGE[@]}"
            sudo flatpak install flathub -y "${PACKAGES_TO_MANAGE[@]}"
        elif [ "$action" == "Desinstalar" ]; then
            action_verb="desinstalado"
            action_title="Desinstalación"
            echo "Desinstalando paquetes: ${PACKAGES_TO_MANAGE[@]}"
            sudo flatpak uninstall -y "${PACKAGES_TO_MANAGE[@]}"
        fi

        # Verifica el estado de instalación/desinstalación
        if [ $? -eq 0 ]; then
            whiptail --title "$action_title Completada" \
                --msgbox "Se han $action_verb los siguientes paquetes: \n${PACKAGES_TO_MANAGE[*]}" 10 60
        else
            whiptail --title "Error de $action" \
                --msgbox "Hubo un problema con algunos paquetes" 10 60
        fi

        # Pregunta al usuario si quiere hacer otra operación
        if (whiptail --title "Continuar" --yesno "Quieres realizar otra operación?" 10 60); then
            show_categories_flatpak
        else
            main
        fi
    else
        main
        echo "No se seleccionaron paquetes."
        exit 0
    fi
}

function install_flatpak_packages() {
    show_categories_flatpak
}
