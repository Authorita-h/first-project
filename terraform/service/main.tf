provider "aws" {}

terraform {
  backend "s3" {
    bucket = "remote-state.bucket"
    key    = "service/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${local.workspace}-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.ecs_task_defenition_arn
  desired_count   = var.task_count
}
