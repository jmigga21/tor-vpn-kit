#!/bin/bash

WG_DIR="/etc/wireguard"
WG_INTERFACE="wg0"
SERVER_PORT=51820
CLIENT_NAME="$1"

# Генерация ключей
mkdir -p ${WG_DIR}/keys
cd ${WG_DIR}/keys
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee ${CLIENT_NAME}_private.key | wg pubkey > ${CLIENT_NAME}_public.key

# Сетап интерфейса
mkdir -p ${WG_DIR}
SERVER_IP="10.66.66.1/24"
CLIENT_IP="10.66.66.2/32"

cat > ${WG_DIR}/${WG_INTERFACE}.conf << EOF
[Interface]
Address = ${SERVER_IP}
ListenPort = ${SERVER_PORT}
PrivateKey = $(cat server_private.key)

[Peer]
PublicKey = $(cat ${CLIENT_NAME}_public.key)
AllowedIPs = ${CLIENT_IP}
EOF

cat > ${WG_DIR}/${CLIENT_NAME}.conf << EOF
[Interface]
PrivateKey = $(cat ${CLIENT_NAME}_private.key)
Address = ${CLIENT_IP}
DNS = 1.1.1.1

[Peer]
PublicKey = $(cat server_public.key)
Endpoint = YOUR_VPS_IP:${SERVER_PORT}
AllowedIPs = 0.0.0.0/0
EOF

# Включаем сервис
systemctl enable wg-quick@${WG_INTERFACE}
systemctl start wg-quick@${WG_INTERFACE}
