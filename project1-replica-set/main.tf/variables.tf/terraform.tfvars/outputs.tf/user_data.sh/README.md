
  # README.md 
# Overview This project deploys a 3‑node MongoDB Replica Set on AWS using Terraform. It demonstrates core DBA and cloud engineering skills:
   • VPC design (private + public subnets) 
   • NAT gateway for secure outbound traffic 
   • EC2 provisioning with Terraform
   • MongoDB installation 
   • Replica set configuration 
   • Security groups and network isolation This is the foundation for all future projects in the portfolio.

  # Architecture

Components deployed: • VPC (10.0.0.0/16) • 3 private subnets (one per AZ) • 1 public subnet • Internet Gateway • NAT Gateway • Route tables (public + private) • 3 EC2 instances (MongoDB nodes) • Security Group allowing: • SSH from your IP • MongoDB traffic inside the VPC

  # Replica Set Topology

# rs0
─ MongoDB-Server-0 (us-east-1a) 
─ MongoDB-Server-1 (us-east-1b)
─ MongoDB-Server-2 (us-east-1c)

 # Project Structure

project1-replica-set/ 
  ─ main.tf 
  ─ variables.tf 
  ─ terraform.tfvars 
  ─ outputs.tf 
  ─ user_data.sh 
  ─ README.md

How It Works

Terraform provisions AWS infrastructure Running creates: 
• VPC + subnets 
• NAT gateway
• EC2 instances
• Security groups
• Routing

# EC2 installs MongoDB automatically installs MongoDB 6.0 and configures:

replication: replSetName: "rs0" 
     net: bindIp: 0.0.0.0

# we initialize the replica set manually
      SSH into MongoDB-Server-0:

# We can login by saying mongo (mongosh)

Then run:

rs.initiate({ _id: "rs0", members: [
{ _id: 0, host: "PRIVATE_IP_0:27017" }, { _id: 1, host: "PRIVATE_IP_1:27017" }, { _id: 2, host: "PRIVATE_IP_2:27017" }   

  ] 
})

Then Check status:

rs.status()

# Deployment Instructions

# Initialize Terraform
   terraform init

# Validate configuration 
   terraform validate

# Preview changes
   terraform plan
   
# Deploy 
   terraform apply

 # Security Notes

MongoDB is deployed in private subnets (not publicly accessible)
Only the IP can SSH into the bastion/instances
MongoDB traffic is restricted to the VPC CIDR
