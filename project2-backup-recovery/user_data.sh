
apt install -y awscli

cat << 'EOF' > /usr/local/bin/mongo_backup.sh
#!/bin/bash

DATE=$(date +%F-%H-%M)
BACKUP_DIR="/tmp/mongo-backup-$DATE"

mongodump --out $BACKUP_DIR
tar -czf /tmp/mongo-backup-$DATE.tar.gz $BACKUP_DIR

aws s3 cp /tmp/mongo-backup-$DATE.tar.gz s3://sisay-mongo-backups-12345/

rm -rf $BACKUP_DIR
rm /tmp/mongo-backup-$DATE.tar.gz
EOF

chmod +x /usr/local/bin/mongo_backup.sh

(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/mongo_backup.sh") | crontab -
