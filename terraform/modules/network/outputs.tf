output "vpc_id" {
   description = "The ID of the VPC"
   value       = aws_vpc.this.id
}

output "subnets_groups" {
  description = "A map of subnet groups with their corresponding subnet IDs"
  value = {
   public = values(aws_subnet.public)[*].id
   app = [for k, v in aws_subnet.private : v.id if startswith(k, "app-")]
   db = [for k, v in aws_subnet.private : v.id if startswith(k, "db-")]
   }
}

/*subnets_group is a name, choose any name you want, 
# Know it's like you export the subnet, so The root module (or parent module) can use it.
# Other modules can consume it if the root passes it as a variable.
# Now in the root configuration you can reference the subnet by module.modulename in the root config file. output name in the output file in the child module -module.myapp-subnet.subnet-*

value = {for az, subnet in aws_subnet.public : az => subnet.id} will give:
value = {
  "eu-north-1a" = "subnet-0bb1c79de3EXAMPLE"
  "eu-north-1b" = "subnet-0bb1c79de3EXAMPLE"
}
*/

/*value =  {for k, v in aws_subnet.private : k => v.id} will give:
value = {
   "app-a" = "subnet-0bb1c79de3EXAMPLE"
   "app-b" = "subnet-0bb1c79de3EXAMPLE"
}
*/



# aws_subnet.private is called a map of objects, each object has attributes like id, cidr_block, availability_zone etc.
# so we are using for k,v in aws_subnet.private where k is the key and v is the value (object)
# while aws_subnet.private[app-a] is called a single object, you can access its attributes like aws_subnet.private[app-az1].id etc.
# conceptually it looks like this:
#   aws_subnet.private = {
#      "app-a" = {
#         id = "subnet-0bb1c79de3EXAMPLE"
#         arn = "arn:aws:ec2:region:account-id:subnet/subnet-0bb1c79de3EXAMPLE"
#         vpc_id = "vpc-1a2b3c4d"
#         cidr_block = "10.10.1.0/24"
#         availability_zone = "eu-north-1a"
#   }
#      "app-b" = {
#         id = "subnet-0bb1c79de3EXAMPLE"
#         arn = "arn:aws:ec2:region:account-id:subnet/subnet-0bb1c79de3EXAMPLE"
#         vpc_id = "vpc-1a2b3c4d"
#         cidr_block = "10.10.2.0/24"
#         availability_zone = "eu-north-1b"
#   }
#
#   so aws_subnet.private[app-a] called an object = {
#      id = "subnet-0bb1c79de3EXAMPLE" #id is an attribute
#      arn = "arn:aws:ec2:region:account-id:subnet/subnet-0bb1c79de3EXAMPLE"
#      vpc_id = "vpc-1a2b3c4d"
#      cidr_block = "10.10.1.0/24"
#      availability_zone = "eu-north-1a"
#   }
#
# its not printed like that but terraform internally treats it like this