module "vpc" {
  name                 = var.name
  source               = "github.com/alphaveer/terraform-aws-vpc"
  cidr                 = "10.0.0.0/16"
  separate_db_subnets  = false
  subnet_outer_offsets = [ 2, 2 ]
  subnet_inner_offsets = [ 6, 6 ]
}

module "ecs" {
  source             = "./modules/ecs_cluster"
  name               = var.name
  ssh_key_name       = var.ssh_key_name
  vpc_id             = module.vpc.id
  subnets            = module.vpc.private_subnets
  security_group_ids = list(module.vpc.default_sg)
  instance_type = "t3.medium"

  cluster_size = {
    minimum = 1
    maximum = 2
    desired = 1
  }
}

module "alb" {
  source              = "./modules/alb"
  name                = var.name
  vpc_id              = module.vpc.id
  private_subnets     = module.vpc.private_subnets
  public_subnets      = module.vpc.public_subnets
  security_group_ids  = list(module.vpc.default_sg)
  internal            = false
  ssl_policy          = "ELBSecurityPolicy-TLS-1-2-2017-01"
  ssl_certificate_arn = var.ssl_certificate_arn
}

module "flask" {
  source          = "./modules/ecs_web_service"
  ecs_cluster_arn = module.ecs.cluster_arn
  vpc_id          = module.vpc.id

  alb = {
    priority             = "100"
    subdomain            = "flask"
    listener_arn         = module.alb.listener_arn_https
    health_check_path    = "/"
    health_check_matcher = 200
  }

  service = {
    name          = "flask"
    cpu           = 0
    memory        = 512
    port          = 80
    desired_count = 1
    minimum_count = 1
    maximum_count = 4
  }

  ecr_repository_url    = "nginx"
  environment_variables = []
  secrets               = []
}
