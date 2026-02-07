output "vpc-id" {
    value = module.network.vpc_id
}
output "public-subnet-ids" {
    value = module.network.subnets_groups["public"]
}

output "private-app-subnet-ids" {
    value = module.network.subnets_groups["app"]
}

output "private-db-subnet-ids" {
    value = module.network.subnets_groups["db"]
}

output "app-server-infos" {
  value = module.compute.server-infos["web-server"]
}
output "monitoring-server-infos" {
  value = module.compute.server-infos["ansible-server"]
}



