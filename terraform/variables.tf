variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Name of EC2 Key Pair"
  type        = string
  default     = "AtulsAuthBasic"  # Leave empty if no key; we'll use password auth for Ansible
}
