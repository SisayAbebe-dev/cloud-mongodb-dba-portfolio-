
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

# Create and configure the Keyfile securely injected by Terraform
echo "${keyfile_content}" > /etc/mongo-keyfile
chmod 400 /etc/mongo-keyfile
chown mongodb:mongodb /etc/mongo-keyfile

# Configure MongoDB with Keyfile Auth enabled
cat <<EOF > /etc/mongod.conf
storage:
  dbPath: /var/lib/mongodb
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 0.0.0.0
replication:
  replSetName: "rs0"
security:
  authorization: "enabled"
  keyFile: /etc/mongo-keyfile
EOF

# Enable and start MongoDB
systemctl enable mongod
systemctl restart mongod
