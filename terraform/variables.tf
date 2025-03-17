variable "base_region" {
  description = "AWS region"
  type    = string
  default = "us-west-2" 
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# Security Group names
variable "frontend_sg_name" {
  description = "Name of the frontend security group"
  type        = string
  default     = "frontend-sg"
}

variable "backend_sg_name" {
  description = "Name of the backend security group(worker)"
  type        = string
  default     = "backend-sg"
}

variable "redis_sg_name" {
  description = "Name of the Redis security group"
  type        = string
  default     = "redis-sg"
}

variable "alb_sg_name" {
  description = "Name of the ALB security group"
  type        = string
  default     = "alb-sg"
}

variable "s3_bucket_name" {
  description = "Name of the Amazon S3 bucket for storing terraform state"
  type    = string
  default = "devops-s3-bucket-terraform-state-storage" 
}

variable "dynamodb_table_name" {
  description = "Name of the  DynamoDB table for terraform state locking"
  type    = string
  default = "devops-terraform-state-lock" 
}
