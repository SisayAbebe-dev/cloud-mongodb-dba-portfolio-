README.md

  # Project 1 — MongoDB Replica Set on AWS (Terraform)
# This project deploys a secure 3‑node MongoDB replica set on AWS using Terraform.

Secure internal authentication, private network isolation, replica set configuration, and infrastructure-as-code.

# Architecture Overview

AWS VPC (10.0.0.0/16)

Public Subnet (Bastion Host)

Private Subnets (Database Nodes)

Security Group allowing:

SSH from my home IP to Bastion Host

SSH from Bastion to Private Nodes

MongoDB internal traffic between nodes (Port 27017)

# EC2 Instances:

Bastion Host (Jump Box)

MongoDB-Node-1 (PRIMARY)

MongoDB-Node-2 (SECONDARY)

MongoDB-Node-3 (SECONDARY)

@ Security: Keyfile Authentication for inter-node MongoDB communication and RBAC.

# Project Structure

── main.tf 
── variables.tf 
── outputs.tf
── terraform.tfvars
── user_data.sh
── README.md

#  Terraform Plan

Before applying, I ran a plan to preview the infrastructure changes and ensure all resources (VPC, Subnets, Bastion, and DB Nodes) were correctly defined.

<img width="1887" height="998" alt="image" src="https://github.com/user-attachments/assets/a0583263-82c0-43b1-827d-3575c21b62df" />


# Terraform Apply
# I deployed the full infrastructure:
# Terraform created:

VPC

Public and Private Subnets

Route tables & NAT Gateways

Security groups

1 Bastion Host & 3 MongoDB EC2 instances

<img width="1920" height="1020" alt="image" src="https://github.com/user-attachments/assets/7b55c79c-eec0-4fd6-b97b-133f9aec991d" />

#  EC2 Instances Running
Verified that all instances (Bastion and 3 MongoDB nodes) were initialized and running successfully within the AWS EC2 dashboard.

<img width="1920" height="1072" alt="image" src="https://github.com/user-attachments/assets/70d49a39-de5f-487e-91f4-55c874acebd3" />


#  Subnet Verification
I verified the creation of the isolated private subnets to ensure the database is not exposed to the public internet then
# And all nodes with their ips 
  bastion-public-ip 34.224.78.141 i used public ip to enter first into the private nodes to access them(server jumper)
  
  node1-private-ip 10.0.10.60
  
  node2-private-ip 10.0.11.32
  
  node3-private-ip 10.0.12.52

# SSH into Node 1
I connected to the primary node securely via the Bastion Host:

# Bash

    ssh -A ubuntu@<bastion-public-ip>  Then to ssh ubuntu@<node1-private-ip> 

<img width="1920" height="1021" alt="image" src="https://github.com/user-attachments/assets/ce0834d6-42ff-467d-9bcd-4014bf7ca19f" />


# Checking Status:

@ Bash

sudo systemctl status mongod

MongoDB is active and running on the primary node as well

<img width="1920" height="1022" alt="image" src="https://github.com/user-attachments/assets/f4551e2d-57dd-4dbf-b43e-7ff75ae8ecb6" />

#  Admin User Creation
Before enforcing security, I created the root admin. This ensures that a "Master Key" exists before the database is locked


use admin
db.createUser({ 
  user: "sisay_admin", 
  pwd: "sisay123456", 
  roles: [ { role: "root", db: "admin" } ]
})


#  Keyfile Generation & Security Enforcement
I generated a 756-byte OpenSSL keyfile and distributed it to all three nodes. I then updated the mongod.conf YAML file on every node to enforce the security layer:

YAML
security:
  authorization: enabled
  keyFile: /var/lib/mongodb/security/mongodb-keyfile
  
# System Lockdown:
I restarted the mongod service on all nodes. To verify the lock, I attempted to run a command without credentials, which correctly returned an Unauthorized error.
<img width="1920" height="1027" alt="image" src="https://github.com/user-attachments/assets/b687107c-de23-4933-a9c2-706377452bd7" />


#  — Authenticated Cluster 

With the security active the nodes required an authenticated to form the replica set. I logged in using the admin credentials created:

# Bash

mongosh -u sisay_admin -p sisay123456--authenticationDatabase admin

# I added the secondary nodes to the cluster:

rs.add("10.0.11.32:27017")
rs.add("10.0.12.52:27017")

#  — Health Verification

I verified the cluster health to ensure the keyFile was allowing heartbeats between nodes, then performed a final data test.

 Health Check:

rs.status().members.map(m => ({name: m.name, state: m.stateStr, health: m.health}))


<img width="1920" height="1023" alt="image" src="https://github.com/user-attachments/assets/4ecb9524-3c1b-4e1e-a87a-2354e6571ebd" />


# Database Write Test:


db.test.insertOne({ "item": "portfolio", "status": "completed" })

<img width="1920" height="1023" alt="image" src="https://github.com/user-attachments/assets/6150d3f7-b48f-4662-908b-96d8398546bb" />


# Notes

- MongoDB is deployed in **private subnets** (not publicly accessible)
  To align with AWS security best practices, I moved the database tier to Private Subnets, removing all public entry points. I implemented a Bastion Host architecture and utilized SSH Agent Forwarding to manage the nodes. This ensures that the database is never directly exposed to the internet, significantly reducing the attack surface
- Only my IP can SSH into the bastion/ then to instances
- MongoDB traffic is restricted to the VPC CIDR

Integrated a dynamic S3 bucket naming strategy using random_id to ensure idempotent deployments and global uniqueness for backup storage
