# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "AIM-main" {
  cidr_block = "172.99.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "AIM-private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.AIM-main.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.AIM-main.id
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "AIM-public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.AIM-main.cidr_block, 2, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.AIM-main.id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "AIM-igw" {
  vpc_id = aws_vpc.AIM-main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "AIM-internet_access" {
  route_table_id         = aws_vpc.AIM-main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.AIM-igw.id
}


# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "AIM-private" {
  count  = var.az_count
  vpc_id = aws_vpc.AIM-main.id
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "AIM-private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.AIM-private.*.id, count.index)
  route_table_id = element(aws_route_table.AIM-private.*.id, count.index)
}
# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "AIM" {
  name        = "AIM.dhwebsupport.com"
  description = "AIM Django App"
  vpc         = aws_vpc.AIM-main.id
}
# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "AIM-backend" {
  name        = "AIM-backend.dhwebsupport.com"
  description = "Starcenter Grafana"
  vpc         = aws_vpc.AIM-main.id
}

resource "aws_service_discovery_service" "AIM" {
  name = "AIM"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.AIM.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


resource "aws_service_discovery_service" "AIM-backend" {
  name = "starcenter-backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.AIM-backend.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
