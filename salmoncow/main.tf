# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

# Create VPC
module "vpc_one" {
  source = "../modules/network/vpc/vpc_init/"

  ou                      = local.ou
  use_case                = local.use_case
  tags                    = local.tags
  cidr_block              = "10.0.0.0/16"
  secondary_cidr_blocks   = ["100.64.0.0/16"]
  private_subnets         = { "10.0.0.0/24" = "us-east-1a", "10.0.1.0/24" = "us-east-1b" } # TODO: allow literal AZ as well as logical (default)
  public_subnets          = { "10.0.2.0/24" = "us-east-1a", "10.0.3.0/24" = "us-east-1b" }
  internal_subnets        = { "100.64.0.0/17" = "us-east-1a", "100.64.128.0/17" = "us-east-1b" }
  map_public_ip_on_launch = true
  # nat_gw                  = true 
}
output "vpc_id" { value = module.vpc_one.vpc_id }
output "private_subnet_ids" { value = module.vpc_one.private_subnet_ids }
output "public_subnet_ids" { value = module.vpc_one.public_subnet_ids }
output "internal_subnet_ids" { value = module.vpc_one.internal_subnet_ids }

# Create VPC NACLs
module "vpc_one_nacl" {
  source = "../modules/network/vpc/nacl/"

  ou       = local.ou
  use_case = local.use_case
  tags     = local.tags

  vpc_id = module.vpc_one.vpc_id

  private_subnet_ids  = module.vpc_one.private_subnet_ids
  public_subnet_ids   = module.vpc_one.public_subnet_ids
  internal_subnet_ids = module.vpc_one.internal_subnet_ids
}

# ------------------------------------------------------------------------------
# S3
# ------------------------------------------------------------------------------

module "s3_bucket_salmoncow" {
  source = "../modules/storage/s3/s3_bucket/"

  ou       = local.ou
  use_case = local.use_case
  tags     = local.tags

  bucket_name = local.use_case
}