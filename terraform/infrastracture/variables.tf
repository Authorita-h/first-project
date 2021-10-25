locals {
  workspace = terraform.workspace
  s3_bucket_name = "${local.workspace}.bucket.frontend"
  ecr_repository_name = "${local.workspace}.ecr.backend"
  s3_origin_id = "S3Origin"
  ecs_cluster_name = "${local.workspace}-cluster"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "max_instances" {
  default = 1
}

variable "min_instances" {
  default = 1
}

variable "desired_instances" {
  default = 1
}