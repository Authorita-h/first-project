provider "aws" {}

resource "aws_security_group" "new_security_group" {
  name        = "${local.workspace}-security-group"
  description = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "s3_frontend" {
  bucket = local.s3_bucket_name
  acl    = "public-read"
  policy = data.template_file.bucket_policies_template.rendered

  tags = {
    "Name"        = "Bucket for ${local.workspace}"
    "Environment" = "${local.workspace}"
  }
}

resource "aws_ecr_repository" "ecr_backend" {
  name = local.ecr_repository_name

  tags = {
    "Name"        = "Repository for ${local.workspace}"
    "Environment" = "${local.workspace}"
  }
}

resource "aws_cloudfront_distribution" "cf_frontend" {
  origin {
    domain_name = aws_s3_bucket.s3_frontend.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  default_root_object = "index.html"
  enabled             = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name
}

resource "aws_launch_configuration" "new_launch_configuration" {
  name                        = "${local.workspace}-launch-configuration"
  associate_public_ip_address = true
  image_id                    = data.aws_ami.ami_latest_amazon.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.new_security_group.id]
  user_data                   = data.template_file.instance_config_template.rendered
}

resource "aws_autoscaling_group" "new_asg" {
  name                 = "${local.workspace}-autoscaling-group"
  max_size             = var.max_instances
  min_size             = var.min_instances
  desired_capacity     = var.desired_instances
  launch_configuration = aws_launch_configuration.new_launch_configuration.name
  availability_zones   = data.aws_availability_zones.az.names
}

resource "aws_ecs_task_definition" "ecs_new_task" {
  family                = "${local.workspace}-service"
  container_definitions = data.template_file.ecr_image_path.rendered
}
resource "aws_iam_role" "ecs_agent" {
  name               = "${local.workspace}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "${local.workspace}-ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

output "ecr_repository" {
  value = aws_ecr_repository.ecr_backend.repository_url
}
