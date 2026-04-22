#!/usr/bin/env bash

set -e

error() {
  echo -e "\e[91m[ERROR]\e[39m $1"
  exit 1
}

info() {
  echo -e "\e[96m[INFO]\e[39m $1"
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    error "Execute como root: use 'sudo' antes do comando."
  fi
}

check_internet() {
  info "Checking internet connection..."
  if wget -q --spider https://github.com; then
    info "Online ✔"
  else
    error "Sem conexão com a internet."
  fi
}

create_dirs() {
  info "Criando diretórios..."
  mkdir -p /portainer/Files/AppData/Config/Caddy || error "Falha ao criar diretórios."
}

download_caddyfile() {
  info "Baixando Caddyfile..."
  wget -qO /portainer/Files/AppData/Config/Caddy/Caddyfile \
    https://raw.githubusercontent.com/pi-hosted/pi-hosted/master/configs/Caddyfile \
    || error "Falha ao baixar Caddyfile."

  # validação simples pra evitar HTML acidental
  if grep -q "<html" /portainer/Files/AppData/Config/Caddy/Caddyfile; then
    error "Arquivo baixado parece ser HTML, não um Caddyfile válido."
  fi
}

main() {
  check_root
  check_internet
  create_dirs
  download_caddyfile

  info "Tudo pronto! 🎉"
}

main
