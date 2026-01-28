variable "vpc_cidr_block" {
    type = string
}

variable "full_name" {
     type = string
}

variable "environment" {
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
