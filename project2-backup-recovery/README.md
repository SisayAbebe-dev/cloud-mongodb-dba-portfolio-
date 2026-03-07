
# MongoDB Backup & Recovery on AWS (Project 2)

This project is part of my Cloud + MongoDB DBA portfolio.
Here I built a fully automated MongoDB backup and recovery system using AWS and Terraform.
The setup uses:
• 	1 EC2 backup server (cost‑optimized)
• 	S3 bucket for storing backups
• 	IAM role + policy for secure uploads
• 	Cron job to run backups every night at 2 AM
• 	Restore script to recover the latest backup when needed

# Architecture Summary
• 	A single EC2 instance runs , compresses the backup, and uploads it to S3.
• 	Backups run automatically every day at 2 AM.
• 	IAM role gives the EC2 instance permission to upload to S3.
• 	A manual "restore.sh" script restores the latest backup from S3.
I used one EC2 instance instead of three to reduce cost. A backup server doesn’t need replication or elections, so one node is enough.

  # What Terraform Builds
# Networking
• 	VPC (10.0.0.0/16)
• 	Public and private subnets
• 	Internet Gateway + NAT Gatewayv
• 	Route tables and associations
# Compute
• 	One EC2 instance (backup server)
• 	Private subnet for security
• 	Security group allowing:
• 	SSH from my IP
• 	MongoDB internal access
# Storage
• 	S3 bucket: sisay-mongo-backups-12345
# IAM
• 	IAM role for EC2
• 	IAM policy allowing:
• 	    s3:putObject
• 	    s3:listBucket
• 	Instance profile attached to EC2
# Automation
- user_data.sh installs:
- MongoDB tools
- AWS CLI
- Backup script
- Cron job

# user_data.sh (ideas)
The EC2 instance automatically:
- Installs MongoDB tools
- Installs AWS CLI
- Creates /usr/local/bin/mongo_backup.sh
- Schedules a cron job at 2 AM
- Uploads compressed backups to S3
- Backups are stored as:
                  :mongo-backup-YYYY-MM-DD-HH-MM.tar.gz

# Restore Script
 # added a restore.sh script that:
- Finds the newest backup in S3
- Downloads it
- Extracts it
- Runs mongorestore
# It means backup and restore lifecycle.

#  Deployment

Initialize Terraform:
  terraform init


Preview changes:
  terraform plan


Then deploy:
  terraform apply
  
# How I Restore a Backup
After the backup server is deployed  I restored the latest backup from S3 by connecting to the EC2 instance and running the restore script manually.

# 1. SSH into the EC2 instance
ssh -i my-key.pem ubuntu@<my EC2-IP***>


2. Upload the restore script
scp -i my-key.pem restore.sh ubuntu@<my EC2-IP***>:/home/ubuntu/


3. Run the restore script
chmod +x restore.sh
./restore.sh

# This script downloads the newest backup from S3, extracts it and restores it using (mongorestore).






