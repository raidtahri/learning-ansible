variable "full_name" {
    type = string
}

variable "environment" {
    type = string
}
variable "vpc_id" {
  type = string
}

variable "security_groups" {
    description = "Security groups defined per role"
    type = map(object({
        ingress = list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
        }))
        egress = optional(list(object({
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_blocks = list(string)
        })), [])
        extra_tags = optional(map(string), {})
    }))
}

variable "public_key_path" {
    type = string
}


variable "instances" {
    type = map(object({#object when each element has diffirent types -string, boolean, number,etc.-
        instance_type        = string
        subnet_role          = string
        iam_instance_profile = optional(string)
        extra_tags           = optional(map(string), {}) #string when each element has same type -string-
    }))
}

variable "ami_owners" {
    type = list(string)
}

variable "ami_name_pattern" {
    type = string
}
variable "subnets_groups" {
    description = "subnets grouped by role"
    type = map(list(string))
}


