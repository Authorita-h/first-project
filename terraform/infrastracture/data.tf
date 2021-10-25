data "aws_availability_zones" "az" {}
data "aws_ami" "ami_latest_amazon" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
data "aws_vpc" "vpc" {
  default = true
}
data "aws_subnets" "subnets" {}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "instance_config_template" {
  template = file("templates/script.sh.tpl")
  vars = {
    workspace = local.workspace
  }
}

data "template_file" "bucket_policies_template" {
  template = file("templates/bucket_policies.json.tpl")
  vars = {
    bucket_name = local.s3_bucket_name
  }
}

data "template_file" "ecr_image_path" {
  template = file("templates/task_defenition.json.tpl")
  vars = {
    workspace = local.workspace
    image_repository_path = aws_ecr_repository.ecr_backend.repository_url
  }
}
