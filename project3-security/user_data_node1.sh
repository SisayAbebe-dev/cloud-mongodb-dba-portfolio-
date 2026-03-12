#!/bin/bash

# Update system
apt-get update -y

# Install MongoDB
apt-get install -y gnupg curl

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] \
   https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
   | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

apt-get update -y
apt-get install -y mongodb-org

# Create keyfile directory
mkdir -p /etc/mongo
echo "MySecretClusterKey123" > /etc/mongo/keyfile
chmod 600 /etc/mongo/keyfile
chown mongodb:mongodb /etc/mongo/keyfile

# Configure mongod
cat <<EOF >/etc/mongod.conf
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
net:
  port: 27017
  bindIp: 0.0.0.0
security:
  keyFile: /etc/mongo/keyfile
replication:
  replSetName: "rs0"
EOF

# Start MongoDB
systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to start
sleep 20

# Initiate replica set
mongosh --eval 'rs.initiate({
  _id: "rs0",
  members: [{ _id: 0, host: "localhost:27017" }]
});'


