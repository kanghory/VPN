#!/bin/bash
# Autobackup Script - Membuat Jadwal Backup via crontab

BACKUP_SCRIPT="/usr/bin/backup"

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
echo "=================================="
read -rp "Pilih opsi (1-6): " pilihan

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
    *)
        echo "Pilihan tidak valid!"
        exit 1
        ;;
esac

# Tambahkan jadwal ke crontab
(crontab -l 2>/dev/null | grep -v "$BACKUP_SCRIPT"; echo "$cron_time /bin/bash $BACKUP_SCRIPT") | crontab -

echo "Jadwal backup berhasil diatur!"
