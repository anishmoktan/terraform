data "aws_availability_zones" "available" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
  state = "available"
}

variable "active_zone_count" {
  type        = number
  description = "Number of zones in which to create subnets/resources"
  default     = 2
}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
  source = "terraform-aws-modules/vpc/aws"
  # version = "4.0.1"

  name = "${var.environment}-anishmoktan-network"
  cidr = var.environment_map[var.environment].vpc_cidr

  azs = [
    for num in range(0, var.active_zone_count) :
    data.aws_availability_zones.available.names[num]
  ]

  public_subnets = [
    for num in range(0, var.active_zone_count) :
    cidrsubnet(var.environment_map[var.environment].vpc_cidr, 8, num + 1)
  ]

  private_subnets = [
    for num in range(0, var.active_zone_count) :
    cidrsubnet(var.environment_map[var.environment].vpc_cidr, 8, (num * 10) + 10)
  ]

  #Database
  database_subnets = [
    for num in range(0, var.active_zone_count) :
    cidrsubnet(var.environment_map[var.environment].vpc_cidr, 8, (num * 10) + 12)
  ]
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  #Redshift
  redshift_subnets = [
    for num in range(0, var.active_zone_count) :
    cidrsubnet(var.environment_map[var.environment].vpc_cidr, 8, (num * 10) + 14)
  ]
  create_redshift_subnet_route_table = true

  enable_nat_gateway       = true
  single_nat_gateway       = true
  one_nat_gateway_per_az   = false
  dhcp_options_domain_name = var.environment_map[var.environment].domains.anishmoktan
  enable_dhcp_options      = true
  enable_dns_hostnames     = true
  enable_dns_support       = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint" "s3" {
  #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
  vpc_id = module.vpc.vpc_id
  #VPC endpoint for S3 access in us-east-1 region
  service_name = "com.amazonaws.us-east-1.s3"

  tags = {
    Environment = var.environment
  }
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  route_table_id  = module.vpc.public_route_table_ids[0]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  route_table_id  = module.vpc.private_route_table_ids[0]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
