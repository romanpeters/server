locals {
  hosts = csvdecode(file("${path.module}/../hosts.csv"))
  hosts_map = { for host in local.hosts : host.name => host }
} 