variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for MongoDB nodes"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "my existing AWS Key Pair"
  type        = string
  default     = "my keypair"
}

variable "my_ip" {
  description = "my local IP for SSH access"
  type        = string
default     = "My current ip/32"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0b6c6ebed2801a5cb"
}}
