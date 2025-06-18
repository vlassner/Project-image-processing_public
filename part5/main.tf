/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): Victoria Lassner
*/
 
/* ---------------------- *
* Security Configuration *
* ---------------------- */
 
provider "aws" {
  region = var.region
}
 
// TODOd: create the project's task execution role
resource "aws_iam_role" "prj_01_task_execution_role" {
  name = "prj_01_task_execution_role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
 
// TODOd: attach the task execution policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.prj_01_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
 
// TODOd: create the project's task role
resource "aws_iam_role" "prj_01_task_role" {
    name = "prj01_task_role"
 
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
 
// TODOd: create the project's s3 access policy
resource "aws_iam_policy" "prj_01_s3_access_policy" {
    name = "prj01_s3accesspolicy"
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}
 
// TODOd: attach the s3 access policy to the role
resource "aws_iam_role_policy_attachment" "prj_01_task_role_policy_attachment" {
    role       = aws_iam_role.prj_01_task_role.name
    policy_arn = aws_iam_policy.prj_01_s3_access_policy.arn
}
 
// TODOd: create the project's security group
resource "aws_security_group" "security_group" {
    name        = "prj_01_security_group"
    vpc_id      = var.vpc_id
 
    ingress {
        from_port   = 5000
        to_port     = 5000
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
 
/* ---------------------- *
* Services Configuration *
* ---------------------- */
 
// TODOd: create the project's task definition
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "prj_01_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]     
  cpu                      = "256" 
  memory                   = "512"
  execution_role_arn       = aws_iam_role.prj_01_task_execution_role.arn
  task_role_arn            = aws_iam_role.prj_01_task_role.arn
 
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
 
  container_definitions    = jsonencode([
    {
      name      = "prj01"
      image     = var.docker_image_uri
      essential = true,
      portMappings = [
        {
          containerPort = 5000,
          hostPort      = 5000
        }
      ]
    }
  ])
}
 
 
// TODOd: create an ECS cluster
resource "aws_ecs_cluster" "cluster" {
    name = "prj_01_cluster"
}
 
// TODOd: create a service to run a single task from the task definition
resource "aws_ecs_service" "service" {
  name            = "prj_01_service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
 
  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [aws_security_group.security_group.id]
    assign_public_ip = true
  }
}