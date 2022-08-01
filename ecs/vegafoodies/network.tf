# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "vegafoodies-main" {
  cidr_block = "172.66.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "vegafoodies-private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.vegafoodies-main.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.vegafoodies-main.id
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "vegafoodies-public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.vegafoodies-main.cidr_block, 4, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.vegafoodies-main.id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "vegafoodies-igw" {
  vpc_id = aws_vpc.vegafoodies-main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "vegafoodies-internet_access" {
  route_table_id         = aws_vpc.vegafoodies-main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vegafoodies-igw.id
}



# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "vegafoodies-private" {
  count  = var.az_count
  vpc_id = aws_vpc.vegafoodies-main.id

}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "vegafoodies-private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.vegafoodies-private.*.id, count.index)
  route_table_id = element(aws_route_table.vegafoodies-private.*.id, count.index)
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "vegafoodies" {
  name        = "vegafoodies.dhwebsupport.com"
  description = "vegafoodies Django App"
  vpc         = aws_vpc.vegafoodies-main.id
}
# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "vegafoodies-backend" {
  name        = "backend.dhwebsupport.com"
  description = "vegafoodies Grafana"
  vpc         = aws_vpc.vegafoodies-main.id
}
# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "vegafoodies-nginx" {
  name        = "vegafoodies-nginx.dhwebsupport.com"
  description = "vegafoodies nginx"
  vpc         = aws_vpc.vegafoodies-main.id
}
resource "aws_service_discovery_service" "vegafoodies" {
  name = "vegafoodies-app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.vegafoodies.id

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


resource "aws_service_discovery_service" "vegafoodies-backend" {
  name = "vegafoodies-grafana"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.vegafoodies-backend.id

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
