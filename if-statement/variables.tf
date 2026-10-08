variable "prefix" {
  description = "Student ID prefix"
  type        = string
  default     = "houachibane"
}

variable "create_instance" {
  description = "Whether to create the VM instance"
  type        = bool
  default     = false
}