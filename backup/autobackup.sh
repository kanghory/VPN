#!/bin/bash
# SL
# ==========================================
# Color Definitions
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting Host Information
clear
IP=$(curl -sS ipv4.icanhazip.com)
date=$(date +"%Y-%m-%d")

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ON]${Font_color_suffix}"
Error="${Red_font_prefix}[OFF]${Font_color_suffix}"

# Check if autobackup is enabled
cek=$(grep -c -E "^# BEGIN_Backup" /etc/crontab)
sts=$([[ "$cek" = "1" ]] && echo "$Info" || echo "$Error")

# Default backup interval in hours
BACKUP_HOUR=1

# Function to Start Autobackup
function start() {
    email=$(cat /home/email)
    if [[ -z "$email" ]]; then
        echo "Please enter your email"
        read -rp "Email: " -e email
        echo "$email" > /home/email
    fi

    # Remove existing backup entry if it exists
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    # Schedule backup according to the set interval
    echo -e "# BEGIN_Backup\n0 */$BACKUP_HOUR * * * root backup >> /var/log/backup.log 2>&1\n# END_Backup" >> /etc/crontab

    service cron restart
    sleep 1
    echo "Please wait..."
    clear
    echo "Autobackup has been started."
    echo "Data will be backed up automatically every $BACKUP_HOUR hour(s)."
    exit 0
}

# Function to Stop Autobackup
function stop() {
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab
    service cron restart
    sleep 1
    echo "Please wait..."
    clear
    echo "Autobackup has been stopped."
    exit 0
}

# Function to Change Recipient Email
function gantipenerima() {
    echo "Please enter your email"
    read -rp "Email: " -e email
    echo "$email" > /home/email
}

# Function to Change Sender Email Configuration
function gantipengirim() {
    local email="andyyuda51@gmail.com"
    local pwdd="hzwzftoxrlftohpf"
    cat <<EOF > /etc/msmtprc
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account default
host smtp.gmail.com
port 587
auth on
user $email
from $email
password $pwdd
logfile ~/.msmtp.log
EOF

    chmod 600 /etc/msmtprc
    echo "SMTP configuration has been updated."
}

# Function to Test Email Sending
function testemail() {
    email=$(cat /home/email)
    if [[ -z "$email" ]]; then
        echo "Email penerima belum diatur. Silakan masukkan email terlebih dahulu."
        gantipenerima
        email=$(cat /home/email)  # Reload email setelah diatur
    fi

    echo -e "Percobaan kirim email dari VPS\nIP VPS: $IP\nTanggal: $date" | msmtp --debug --from=default -t "$email" > /dev/null 2>&1


    if [[ $? -eq 0 ]]; then
        echo "Email berhasil dikirim ke $email."
    else
        echo "Gagal mengirim email ke $email. Periksa log untuk detail lebih lanjut."
    fi
}

# Function to Check Crontab Schedule
function cek_jadwal() {
    echo -e "=============================="
    echo -e "       Jadwal Crontab        "
    echo -e "=============================="
    nl /etc/crontab  # Menampilkan isi dari /etc/crontab dengan nomor urut
    echo -e "=============================="
    read -rp "Press any key to return to the main menu..."
}

# Function to Set Backup Interval
function set_interval() {
    echo "Pilih interval backup (dalam jam):"
    echo "1. 1 Jam"
    echo "2. 2 Jam"
    echo "3. 3 Jam"
    echo "4. 4 Jam"
    echo "5. 6 Jam"
    echo "6. 12 Jam"
    echo "7. 24 Jam"
    read -rp "Masukkan pilihan (1-7): " choice

    case $choice in
        1) BACKUP_HOUR=1 ;;
        2) BACKUP_HOUR=2 ;;
        3) BACKUP_HOUR=3 ;;
        4) BACKUP_HOUR=4 ;;
        5) BACKUP_HOUR=6 ;;
        6) BACKUP_HOUR=12 ;;
        7) BACKUP_HOUR=24 ;;
        *) echo "Pilihan tidak valid, interval tetap pada $BACKUP_HOUR jam." ;;
    esac

    # Remove existing backup entry if it exists
    sed -i "/^# BEGIN_Backup/,/^# END_Backup/d" /etc/crontab

    # Add new cron job
    echo -e "# BEGIN_Backup\n0 */$BACKUP_HOUR * * * root backup >> /var/log/backup.log 2>&1\n# END_Backup" >> /etc/crontab

    service cron restart
    sleep 1
    echo "Interval backup diatur menjadi $BACKUP_HOUR jam."
}

# Main Menu
clear
echo -e "=============================="
echo -e "     Autobackup Data $sts     "
echo -e "=============================="
echo -e "1. Start Autobackup"
echo -e "2. Stop Autobackup"
echo -e "3. Ganti Email Penerima"
echo -e "4. Test kirim Email"
echo -e "5. Cek Jadwal Crontab"
echo -e "6. Atur waktu Backup"
echo -e "=============================="
read -rp "Please Enter The Correct Number: " -e num

# Process User Input
case $num in
    1)
        gantipengirim
        start
        ;;
    2)
        stop
        ;;
    3)
        gantipenerima
        ;;
    4)
        testemail
        ;;
    5)
        cek_jadwal
        ;;
    6)
        set_interval
        ;;
    *)
        clear
        echo "Invalid option. Please try again."
        ;;
esac
