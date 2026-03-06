#!/bin/bash

# Update system
apt update -y
apt install -y gnupg curl

# Add MongoDB repo
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
| tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Install MongoDB
apt update -y
apt install -y mongodb-org

# Enable and start MongoDB
systemctl enable mongod
systemctl start mongod

# Configure replica set
cat <<EOF > /etc/mongod.conf
replication:
  replSetName: "rs0"
net:
  bindIp: 0.0.0.0
EOF

systemctl restart mongod
