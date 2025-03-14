#!/bin/bash
# SL - Backup & Telegram Notification

# ==========================================
# Warna
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# ==========================================
# Setup Direktori Penyimpanan Konfigurasi
CONFIG_DIR="/root/.backup_config"
mkdir -p $CONFIG_DIR

# Mendapatkan IP dan Tanggal
IP=$(wget -qO- ipinfo.io/ip)
DATE=$(date +"%Y-%m-%d")

# ==========================================
# Setup Bot Token dan Admin ID Telegram
BOT_TOKEN_FILE="$CONFIG_DIR/bot_token"
ADMIN_ID_FILE="$CONFIG_DIR/admin_id"

if [[ ! -f "$BOT_TOKEN_FILE" ]]; then
    echo "Masukkan Bot Token Telegram Anda:"
    read -rp "Bot Token: " -e bot_token
    echo "$bot_token" > $BOT_TOKEN_FILE
else
    bot_token=$(cat $BOT_TOKEN_FILE)
fi

if [[ ! -f "$ADMIN_ID_FILE" ]]; then
    echo "Masukkan ID Admin Telegram Anda:"
    read -rp "Admin ID: " -e admin_id
    echo "$admin_id" > $ADMIN_ID_FILE
else
    admin_id=$(cat $ADMIN_ID_FILE)
fi

clear
figlet "Backup"
echo "Mohon Menunggu, Proses Backup sedang berlangsung !!"

# ==========================================
# Proses Backup
rm -rf /root/backup
mkdir /root/backup
cp /etc/passwd /root/backup/
cp /etc/group /root/backup/
cp /etc/shadow /root/backup/
cp /etc/gshadow /root/backup/
cp -r /etc/xray /root/backup/xray
cp -r /root/nsdomain /root/backup/nsdomain
cp -r /etc/slowdns /root/backup/slowdns
cp -r /home/vps/public_html /root/backup/public_html

# Buat Zip Backup
BACKUP_FILE="$IP-$DATE.zip"
cd /root
zip -r $BACKUP_FILE backup > /dev/null 2>&1

# Upload ke Google Drive
rclone copy "/root/$BACKUP_FILE" dr:backup/

# Dapatkan Link Backup
url=$(rclone link dr:backup/$BACKUP_FILE)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"

# ==========================================
# Kirim Notifikasi ke Telegram
message="
<b>🔹 Backup Selesai!</b>

📌 <b>Detail Backup</b>
━━━━━━━━━━━━━━━━━━
🖥️ IP VPS  : <code>$IP</code>
📅 Tanggal : <code>$DATE</code>
📥 Link    : <a href='$link'>Download</a>
━━━━━━━━━━━━━━━━━━
"

curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
     -d chat_id="${admin_id}" \
     -d parse_mode="HTML" \
     -d text="$message" > /dev/null 2>&1

# Hapus File Backup
rm -rf /root/backup
rm -f "/root/$BACKUP_FILE"

# ==========================================
# Tampilkan Hasil di Terminal
clear
echo -e "
Detail Backup
==================================
IP VPS        : $IP
Link Backup   : $link
Tanggal       : $DATE
==================================
"
echo "Silahkan cek Telegram Anda!"
