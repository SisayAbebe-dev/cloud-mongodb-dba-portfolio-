
variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "my_ip" {
  description = "my_ip"
  type        = string
}

variable "key_name" {
  description = "sisay-keypair"
  type        = string
