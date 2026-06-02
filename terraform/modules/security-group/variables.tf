variable "name" {
  description = "Security group name suffix, such as rds-mysql or app."
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for production-style names, usually the environment resource prefix."
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the security group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}

variable "ingress_rules" {
  description = "Named ingress rules. Prefer source_security_group_id for private service access instead of broad CIDRs."
  type = map(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
  }))
  default = {}
}

variable "egress_rules" {
  description = "Named egress rules. Keep egress explicit for database and application security groups."
  type = map(object({
    description              = optional(string)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    self                     = optional(bool)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the security group."
  type        = map(string)
  default     = {}
}
