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
- **Security** Keyfile Authentication for inter-node or MongoDB communication and RBAC
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

##  1 — Terraform Plan

Before applying, I ran a plan to preview the infrastructure changes and ensure all 9 resources were correctly defined.

<img width="1809" height="1017" alt="Image" src="https://github.com/user-attachments/assets/c7c46bba-1a31-49fd-8842-6de590b7d442" />

## 2 — Terraform Apply

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

<img width="1886" height="995" alt="image" src="https://github.com/user-attachments/assets/3b1fe57a-ad76-482d-a6e2-bed3181121e7" />


## 3 — EC2 Instances Running

Verified that all three MongoDB nodes were initialized and running successfully within the AWS EC2 dashboard.

<img width="1857" height="867" alt="image" src="https://github.com/user-attachments/assets/32ed40dd-806f-431e-9fa0-9ae6891453c2" />


##  4 — Subnet Verification

The public subnet (10.0.1.0/24) was created successfully.

<img width="1876" height="868" alt="image" src="https://github.com/user-attachments/assets/1abc1b48-af77-4ec3-98b9-a766fede574f" />



##  5 — SSH into Node 1

I connected to the primary node:

ssh -i mykey.pem ubuntu@< my public-ip-node1>

# Then 

# Checking Status:

sudo systemctl status mongod

<img width="1858" height="639" alt="image" src="https://github.com/user-attachments/assets/97eefd21-ae48-4099-bd76-89be70260f01" />
Mongodb is running as well

# At this stage, only Node 1 is initialized as PRIMARY.
# 5: rs.status()

showing PRIMARY

<img width="1882" height="997" alt="image" src="https://github.com/user-attachments/assets/81301c70-8e94-4131-8c4c-86b8a38889a2" />


# I created Admin User from Node 1

use admin db.createUser({ user: "admin", pwd: "StrongPassword123!", roles: [ { role: "root", db: "admin" } ] })

<img width="1875" height="995" alt="image" src="https://github.com/user-attachments/assets/e4b290ee-6eed-43b2-9ebe-e5f67c8a9a8f" />

Then exit shell
# Testing Authentication login back by user

mongosh -u admin -p Mypassword! --authenticationDatabase admin



# Then
## I Added Node 2 and Node 3 to Replica Set From Node 1:

rs.add("My private ip node2 :27017") 
rs.add("My private ip node3:27017")


# Then:
rs.status()

<img width="1881" height="946" alt="image" src="https://github.com/user-attachments/assets/484fa2d6-435e-4f84-be34-263b5afe3b98" />







