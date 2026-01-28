
locals {
  full_name = "${var.app_name}-${var.environment}"
}

module "network" {
    source = "../../../modules/network/"
    vpc_cidr_block = var.vpc_cidr_block
    full_name = local.full_name
    environment = var.environment
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
/*Module argument names must exactly match the variable names in the child module.
vpc-id is an argument for myapp-subnet module and a variable for subnet child module*/
}

module "compute" {
    source = "../../../modules/compute/"
    full_name = local.full_name
    vpc_id = module.network.vpc_id
    ami_owners = var.ami_owners
    ami_name_pattern = var.ami_name_pattern
    instances = var.instances
    security_groups = var.security_groups
    public_key_path = var.public_key_path
    environment = var.environment
    subnets_groups = module.network.subnets_groups
}
