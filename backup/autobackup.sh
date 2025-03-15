#!/bin/bash
# Autobackup Script - Membuat Jadwal Backup via crontab

BACKUP_SCRIPT="/usr/bin/backup"
CONFIG_DIR="/root/.backup_config"
ADMIN_ID_FILE="$CONFIG_DIR/admin_id"
BOT_TOKEN_FILE="$CONFIG_DIR/bot_token"

# Pastikan skrip backup ada
if [[ ! -f "$BACKUP_SCRIPT" ]]; then
    echo "Error: $BACKUP_SCRIPT tidak ditemukan!"
    exit 1
fi

echo "=================================="
echo "  Auto Backup Scheduler"
echo "=================================="
echo "Jadwal backup saat ini:"
crontab -l | grep "$BACKUP_SCRIPT" || echo "Tidak ada jadwal backup yang ditemukan."
echo "=================================="
echo "1) Setiap 1 Jam"
echo "2) Setiap 6 Jam"
echo "3) Setiap 12 Jam"
echo "4) Setiap 24 Jam (Harian)"
echo "5) Hapus Jadwal Backup"
echo "6) Cek Jadwal Backup"
echo "7) Ganti ID Telegram & Token Bot"
echo "8) Tes Notifikasi Backup"
echo "=================================="
read -rp "Pilih opsi (1-8): " pilihan

case "$pilihan" in
    1)
        cron_time="0 * * * *"  # Setiap 1 jam
        ;;
    2)
        cron_time="0 */6 * * *"  # Setiap 6 jam
        ;;
    3)
        cron_time="0 */12 * * *"  # Setiap 12 jam
        ;;
    4)
        cron_time="0 0 * * *"  # Harian (Tiap tengah malam)
        ;;
    5)
        crontab -l | grep -v "$BACKUP_SCRIPT" | crontab -
        echo "Jadwal backup dihapus."
        exit 0
        ;;
    6)
        echo "=================================="
        echo "Jadwal Backup di Crontab:"
        crontab -l | grep "$BACKUP_SCRIPT" || echo "Tidak ada jadwal backup yang ditemukan."
        echo "=================================="
        exit 0
        ;;
    7)
        echo "=================================="
        echo "Mengganti ID Telegram & Token Bot"
        echo "=================================="
        
        # Cek apakah folder konfigurasi ada
        if [[ ! -d "$CONFIG_DIR" ]]; then
            echo "Folder konfigurasi tidak ditemukan, membuat folder..."
            mkdir -p "$CONFIG_DIR"
        fi
        
        echo "Masukkan ID Telegram baru:"
        read -rp "> " new_admin_id
        echo "$new_admin_id" > "$ADMIN_ID_FILE"
        
        echo "Masukkan Token Bot Telegram baru:"
        read -rp "> " new_bot_token
        echo "$new_bot_token" > "$BOT_TOKEN_FILE"
        
        echo "ID Telegram & Token Bot berhasil diperbarui!"
        echo "=================================="
        exit 0
        ;;
    8)
        echo "=================================="
        echo "Mengirim Tes Notifikasi Backup"
        echo "=================================="
        
        if [[ ! -f "$ADMIN_ID_FILE" || ! -f "$BOT_TOKEN_FILE" ]]; then
            echo "Error: File admin_id atau bot_token tidak ditemukan!"
            exit 1
        fi
        
        TELEGRAM_ID=$(cat "$ADMIN_ID_FILE")
        TELEGRAM_TOKEN=$(cat "$BOT_TOKEN_FILE")
        MESSAGE="🔔 *Notifikasi Backup* 🔔%0A%0ABackup berhasil dijalankan pada $(date +"%Y-%m-%d %H:%M:%S")"

        # Kirim pesan ke Telegram
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
            -d "chat_id=$TELEGRAM_ID" \
            -d "text=$MESSAGE" \
            -d "parse_mode=Markdown"

        echo "Tes notifikasi backup telah dikirim ke Telegram!"
        echo "=================================="
        exit 0
        ;;
    *)
        echo "Pilihan tidak valid!"
        exit 1
        ;;
esac

# Tambahkan jadwal ke crontab
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT"; echo "$cron_time /bin/bash $BACKUP_SCRIPT") | crontab -

echo "Jadwal backup berhasil diatur!"
