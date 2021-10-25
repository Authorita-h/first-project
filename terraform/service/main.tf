provider "aws" {}

resource "aws_ecs_service" "service" {
  name            = "${local.workspace}-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.ecs_task_defenition_arn
  desired_count   = var.task_count
  depends_on = [
    aws_iam_role_policy_attachment.ecs_agent
  ]
}
