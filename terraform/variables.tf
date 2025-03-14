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
