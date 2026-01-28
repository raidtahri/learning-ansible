
output "server-infos" {
  value = {
    for name, instance in aws_instance.this : name => {
      id         = instance.id
      ami        = instance.ami
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}

