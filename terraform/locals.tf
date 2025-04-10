locals {
  hosts = csvdecode(file("${path.module}/../hosts.csv"))
  hosts_map = { for host in local.hosts : host.name => host }
} 

locals {
  services = csvdecode(file("${path.module}/../services.csv"))
  services_map = { for service in local.services : service.name => service }
} 