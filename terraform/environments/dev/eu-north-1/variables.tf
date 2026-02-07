variable "app_name" {
     type = string
}

variable "environment" {
    type = string
  
}

variable "vpc_cidr_block" {
    type = string
}



variable "public_subnets" {
    type = map(object({
        cidr_block = string
        extra_tags = optional(map(string))
    }))
}

variable "private_subnets" {
    type = map(object({
        cidr_block = string
        availability_zone = string
        extra_tags = optional(map(string))
    }))
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
     type = map(object({
         instance_type        = string
         subnet_role          = string
         iam_instance_profile = optional(string)
         script_name          = optional(string)
         extra_tags           = optional(map(string), {})
     }))
 }

 variable "ami_owners" {
     type = list(string)
 }

 variable "ami_name_pattern" {
     type = string
 }


