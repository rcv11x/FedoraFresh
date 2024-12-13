#!/bin/bash 

# Creado por: rcv11x (Alejandro M) (2024)
# Licencia: MIT

source "../scripts/utils.sh"
# source "../scripts/pkg_list.sh"

# Función para mostrar menú de categorías
function show_categories() {
    
    local MENU_ITEMS=()
    for category in "${!DNF_CATEGORIES[@]}"; do
        MENU_ITEMS+=("$category" "Paquetes de $category")
    done

    local SELECTED_CATEGORY=$(whiptail --title "Instala/Desinstala paquetes DNF" \
        --menu "Elige una categoría:" 20 100 10 \
        "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

    # Salir si el usuario cancela
    if [ $? -ne 0 ] || [ -z "$SELECTED_CATEGORY" ]; then
        # echo "Instalación cancelada. Saliendo..."
        main
        exit 0
    fi

    show_options "$SELECTED_CATEGORY"
}

function show_options() {
    local category="$1"
        
    local CHOSEN_OPTION=$(whiptail --title "Instalador de Paquetes - $category" \
        --menu "Selecciona una opción:" 20 60 10 \
        "1" "Instalar paquetes" \
        "2" "Desinstalar paquetes" 3>&1 1>&2 2>&3)

    # Salir si el usuario cancela
    if [ $? -ne 0 ] || [ -z "$CHOSEN_OPTION" ]; then
        # echo "Operación cancelada. Saliendo..."
        main
        exit 0
    fi

    if [ "$CHOSEN_OPTION" == "1" ]; then
        show_packages "Instalar" "$category"
    else
        show_packages "Desinstalar" "$category"
    fi
}

function show_packages() {
    local action="$1"
    local category="$2"
    local action_verb=""
    local action_title=""

    # Verifica si la categoría es válida
    if [ -z "${DNF_CATEGORIES[$category]}" ]; then
        echo "Categoría inválida o no seleccionada. Saliendo..."
        exit 1
    fi

    local PACKAGES=()


    while read -r package descripcion; do
    # Verifica si el paquete está instalado
    if rpm -q "$package" &>/dev/null; then
        STATUS="[INSTALADO]"
    else
        STATUS="[NO INSTALADO]"
    fi


    if [ "$action" == "Instalar" ] && [ "$STATUS" == "[NO INSTALADO]" ]; then
        # Solo añade paquetes no instalados para la instalación, sin el STATUS
        PACKAGES+=("$package" "$descripcion" OFF)
    elif [ "$action" == "Desinstalar" ] && [ "$STATUS" == "[INSTALADO]" ]; then
        # Solo añade paquetes instalados para la desinstalación, desmarcados por defecto
        PACKAGES+=("$package" "$descripcion $STATUS" OFF)
    fi
    done <<< "${DNF_CATEGORIES[$category]}"

    local SELECTION=$(whiptail --title "Instalador de Paquetes - $category" \
        --checklist "Selecciona los paquetes a $action:" 20 100 10 \
        "${PACKAGES[@]}" 3>&1 1>&2 2>&3)

    # Sale si el usuario selecciona cancelar
    if [ $? -ne 0 ]; then
        # echo "$action cancelada. Saliendo..."
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
            # sudo dnf update -y
            sudo dnf install -y "${PACKAGES_TO_MANAGE[@]}"
        elif [ "$action" == "Desinstalar" ]; then
            action_verb="desinstalado"
            action_title="Desinstalación"
            echo "Desinstalando paquetes: ${PACKAGES_TO_MANAGE[@]}"
            sudo dnf remove -y "${PACKAGES_TO_MANAGE[@]}"
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
            show_categories
        else
            main
        fi
    else
        main
        echo "No se seleccionaron paquetes."
        exit 0
    fi
}

function install_packages() {
    show_categories
}
