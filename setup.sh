#!/bin/bash

# Проверка root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Запустите от root."
  exit 1
fi

echo "[1/8] Установка зависимостей..."
apt update
apt install -y wireguard openvpn tor obfs4proxy python3-pip iptables-persistent curl

# Установка Python зависимостей
pip3 install flask python-dotenv

echo "[2/8] Клонирование репозитория..."
git clone https://github.com/jmigga21/tor-vpn-kit.git
cd tor-vpn-kit

# Конфигурация VPN (WireGuard или OpenVPN) и Tor
./server/wireguard.sh

# Запуск web-интерфейса
echo "[3/8] Запуск веб-сервера..."
cd web
python3 app.py
