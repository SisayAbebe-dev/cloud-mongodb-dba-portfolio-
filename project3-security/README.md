# MongoDB Security & Hardening (Replica Set with Keyfile Authentication)

# This project deploys a secure 3‑node MongoDB replica set on AWS using Terraform and user_data automation.  
# Secure internal authentication, replica set configuration, automation, and infrastructure-as-code.

---

## Architecture Overview

- **AWS VPC** (10.0.0.0/16)
- **Public Subnet** (10.0.1.0/24)
- **Security Group** allowing:
  - SSH from my home IP
  - MongoDB internal traffic between nodes
- **3 EC2 Instances**:
  - MongoDB-Node-1 (PRIMARY)
  - MongoDB-Node-2 (SECONDARY)
  - MongoDB-Node-3 (SECONDARY)
- **Keyfile Authentication** for internal MongoDB communication
- **Automated installation** using user_data scripts

##  Project Structure

── main.tf 
── variables.tf 
── terraform.tfvars 
── outputs.tf 
── keyfile 
── user_data_node1.sh 
── user_data_node2.sh 
── user_data_node3.sh 
── README.md

## Step 1 — Terraform Plan

Before applying, I ran:

<img width="1809" height="1017" alt="Image" src="https://github.com/user-attachments/assets/c7c46bba-1a31-49fd-8842-6de590b7d442" />

## Step 2 — Terraform Apply

I deployed the full infrastructure:

Terraform created:
- VPC  
- Subnet  
- Route table  
- Internet gateway  
- Security group  
- 3 MongoDB EC2 instances  
- Uploaded keyfile  
- Ran user_data scripts  

**📸 Screenshot


## Step 3 — EC2 Instances Running

After deployment, all 3 MongoDB nodes appeared in the EC2 dashboard.

**📸 Screenshot


##  Step 4 — Subnet Verification

The public subnet (10.0.1.0/24) was created successfully.

**📸 Screenshot 


## Step 5 — SSH into Node 1

I connected to the primary node:

ssh -i mykey.pem ubuntu@<my public-ip-node1>

# Then checked MongoDB:

mongo rs.status()

At this stage, only Node 1 is PRIMARY.

**📸 Screenshot #5: rs.status() showing PRIMARY only**  
*(insert screenshot here)*

---

## I Added Node 2 and Node 3 to Replica Set From Node 1:

rs.add("MongoDB-Node-2:27017") 
rs.add("MongoDB-Node-3:27017")


# Then:
rs.status()

**📸 Screenshot #6: Final Replica Set Status (PRIMARY + 2 SECONDARIES)**  
*(insert screenshot here)*

# I created Admin User from Node 1

use admin db.createUser({ user: "admin", pwd: "StrongPassword123!", roles: [ { role: "root", db: "admin" } ] })


**📸 Screenshot #7: Admin User Creation**  
*(insert screenshot here)*

# Testing Authentication

mongo -u admin -p StrongPassword123! --authenticationDatabase admin


**📸 Screenshot #8: Successful Authenticated Login**  
*(insert screenshot here)*x



