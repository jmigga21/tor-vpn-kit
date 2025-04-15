#!/bin/bash

echo "[Tor] Установка и настройка Tor + obfs4..."
apt install -y tor obfs4proxy

cat >> /etc/tor/torrc << EOF
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
UseBridges 1
Bridge obfs4 <IP>:<PORT> <FINGERPRINT> cert=<CERT> iat-mode=0
EOF

systemctl restart tor
