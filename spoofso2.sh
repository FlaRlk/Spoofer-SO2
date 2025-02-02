#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

show_banner() {
    clear
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BLUE}      Spoofer Standoff 2 -By Fla${RESET}"
    echo -e "${CYAN}         Kalisto é gay${RESET}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

check_requirements() {
    if ! su -c "whoami" &>/dev/null; then
        echo -e "${RED}[ERRO] Este script precisa de acesso ROOT${RESET}"
        exit 1
    fi
    echo -e "${GREEN}[✓] Acesso ROOT confirmado${RESET}"
    sleep 1
}

show_progress() {
    local duration=$1
    local message=$2
    echo -ne "${YELLOW}$message${RESET}"
    for ((i=duration; i>0; i--)); do
        echo -ne "${YELLOW}$i ${RESET}"
        sleep 1
    done
    echo ""
}

change_android_id() {
    echo -e "\n${CYAN}[*] Iniciando processo de alteração do Android ID...${RESET}"
    
    # gera um novo uuid aleatório
    local UUID=$(cat /proc/sys/kernel/random/uuid)
    echo -e "${BLUE}[*] Novo ID gerado: ${GREEN}$UUID${RESET}"
    sleep 1
    
    echo -e "${YELLOW}[*] Aplicando novo Android ID...${RESET}"
    if su -c "content delete --uri content://settings/secure --where \"name='android_id'\"" &&
       su -c "content insert --uri content://settings/secure --bind name:s:android_id --bind value:s:$UUID"; then
        echo -e "${GREEN}[✓] Android ID alterado com sucesso!${RESET}"
    else
        echo -e "${RED}[✗] Erro ao alterar Android ID${RESET}"
        exit 1
    fi
}

clear_app_data() {
    echo -e "\n${CYAN}[*] Iniciando limpeza de dados...${RESET}"
    
    # lista de apps para limpar
    local apps=(
        "com.google.android.gsf"
        "com.google.android.gms"
        "com.axlebolt.standoff2"
    )

    for app in "${apps[@]}"; do
        echo -e "${YELLOW}[*] Limpando dados de: $app${RESET}"
        if su -c "pm clear $app" &>/dev/null; then
            echo -e "${GREEN}[✓] Dados de $app limpos com sucesso${RESET}"
        else
            echo -e "${RED}[✗] Erro ao limpar dados de $app${RESET}"
        fi
        sleep 1
    done
}

handle_reboot() {
    echo -e "\n${CYAN}[?] Deseja reiniciar agora? (s/n)${RESET}"
    read -r resposta
    resposta=$(echo "$resposta" | tr '[:upper:]' '[:lower:]' | xargs)

    if [[ "$resposta" == "s" ]]; then
        echo -e "${GREEN}[*] Reiniciando o dispositivo...${RESET}"
        show_progress 3 "Reiniciando em: "
        su -c "reboot"
    else
        echo -e "${BLUE}[*] OK, reinicialização cancelada${RESET}"
    fi
}

main() {
    show_banner
    check_requirements
    show_progress 3 "Iniciando em: "
    change_android_id
    clear_app_data
    handle_reboot
}

main
