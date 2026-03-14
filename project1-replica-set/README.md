README.md

  # Project 1 — MongoDB Replica Set on AWS (Terraform)
# Overview
This project deploys a 3‑node MongoDB Replica Set on AWS using Terraform.
It demonstrates core DBA and cloud engineering skills:
• 	VPC design (private + public subnets)
• 	NAT gateway for secure outbound traffic
• 	EC2 provisioning with Terraform
• 	MongoDB installation via
• 	Replica set configuration
• 	Security groups and network isolation
This is the foundation for all future projects in the portfolio.

# Architecture
# Components deployed:
• 	VPC (10.0.0.0/16)
• 	3 private subnets (one per AZ)
• 	1 public subnet
• 	Internet Gateway
• 	NAT Gateway
• 	Route tables (public + private)
• 	3 EC2 instances (MongoDB nodes)
• 	Security Group allowing:
• 	SSH from your IP
• 	MongoDB traffic inside the VPC

# Deployment Instructions

1. Initialize Terraform
     terraform init

2. Validate configuration
     terraform validate

3. Preview changes
     terraform plan

4.Deploy
     terraform apply


# Replica Set Topology   

# rs0
   MongoDB-Server-0 (us-east-1a)
   MongoDB-Server-1 (us-east-1b)
   MongoDB-Server-2 (us-east-1c)

# Project Structure

project1-replica-set/
 
    main.tf](http://main.tf/)
    [variables.tf](http://variables.tf/)
    terraform.tfvars
    outputs.tf](http://outputs.tf/)
    user_data.sh
    README.md](http://readme.md/)

# How It Works

# 1. Terraform provisions AWS infrastructure
Running creates:
  •	VPC + subnets
  •	NAT gateway
  •	EC2 instances
  •	Security groups
  •	Routing
# 2. EC2 installs MongoDB automatically
installs MongoDB 6.0 and configures:

replication:
replSetName: "rs0"
net:
bindIp: 0.0.0.0

# 3. You initialize the replica set manually

    SSH into **MongoDB-Server-0**:

  # We can login by saying  
  mongo  (mongosh)  

# Then run:

rs.initiate({
_id: "rs0",
members: [
{ _id: 0, host: "PRIVATE_IP_0:27017" },
{ _id: 1, host: "PRIVATE_IP_1:27017" },
{ _id: 2, host: "PRIVATE_IP_2:27017" } 

    ]
})

Note: i used Private IPs instead of localhost to allow cross-node communication within the VPC.

# Then Check status:

rs.status()

### The Replication Test

If you haven't already, do a quick "sanity check" to ensure data is actually moving:

- **On Node 1 (Primary):** `db.test.insert({ project: "Complete" })`
- **On Node 2 (Secondary):** Run `db.getMongo().setReadPref("secondary")` and then `db.test.find()`.
- If you see the document, your replication logic is 100% perfect.

🔐 Security Notes

- MongoDB is deployed in **private subnets** (not publicly accessible)
- Only the IP can SSH into the bastion/instances
- MongoDB traffic is restricted to the VPC CIDR



🧩 Overview
This project deploys a 3‑node MongoDB Replica Set on AWS using Terraform.
It demonstrates core DBA and cloud engineering skills:
• 	VPC design (private + public subnets)
• 	NAT gateway for secure outbound traffic
• 	EC2 provisioning with Terraform
• 	MongoDB installation via
• 	Replica set configuration
• 	Security groups and network isolation
This is the foundation for all future projects in the portfolio.

🏗️ Architecture

Components deployed:
• 	VPC (10.0.0.0/16)
• 	3 private subnets (one per AZ)
• 	1 public subnet
• 	Internet Gateway
• 	NAT Gateway
• 	Route tables (public + private)
• 	3 EC2 instances (MongoDB nodes)
• 	Security Group allowing:
• 	SSH from your IP
• 	MongoDB traffic inside the VPC

Replica Set Topology   

rs0
├── MongoDB-Server-0 (us-east-1a)
├── MongoDB-Server-1 (us-east-1b)
└── MongoDB-Server-2 (us-east-1c)

📁 Project Structure

project1-replica-set/
│
├── [main.tf](http://main.tf/)
├── [variables.tf](http://variables.tf/)
├── terraform.tfvars
├── [outputs.tf](http://outputs.tf/)
├── user_data.sh
└── [README.md](http://readme.md/)

  How It Works

1. Terraform provisions AWS infrastructure
Running creates:
•	VPC + subnets
•	NAT gateway
•	EC2 instances
•	Security groups
•	Routing

2. EC2 installs MongoDB automatically
installs MongoDB 6.0 and configures:

replication:
replSetName: "rs0"
net:
bindIp: 0.0.0.0

3. You initialize the replica set manually

SSH into **MongoDB-Server-0**:

  ****We can login by saying  **mongo**  (mongosh)  

Then run:

rs.initiate({
_id: "rs0",
members: [
{ _id: 0, host: "PRIVATE_IP_0:27017" },
{ _id: 1, host: "PRIVATE_IP_1:27017" },
{ _id: 2, host: "PRIVATE_IP_2:27017" } 

    ]
})

Then Check status:

rs.status()

🚀 Deployment Instructions

1. Initialize Terraform
terraform init
2. Validate configuration
terraform validate
3. Preview changes

       terraform plan

  4.  Deploy
       terraform apply

🔐 Security Notes

- MongoDB is deployed in **private subnets** (not publicly accessible)
- Only your IP can SSH into the bastion/instances
- MongoDB traffic is restricted to the VPC CIDR

Integrated a dynamic S3 bucket naming strategy using random_id to ensure idempotent deployments and global uniqueness for backup storage
