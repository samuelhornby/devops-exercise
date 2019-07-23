######################################################################
### This TF file sets up an ECS cluster and a subnet/Security group  #
######################################################################

terraform {
  required_version = ">= 0.11.10"
}


provider "aws" {
  version = "~> 2.7"

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my_cluster"
}

resource "aws_ecs_task_definition" "service" {
  container_definitions    = file("task-definitions/service.json")
  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  volume {
    name      = "service-storage"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }

}

resource "aws_ecs_service" "my_containers" {
  name            = "my_containers"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.cluster_sg.id]
    assign_public_ip = true
  }
}

##################
### Networking ###
##################

resource "aws_vpc" "my-deployment"{
	cidr_block           = "10.20.0.0/16"
	enable_dns_hostnames = true
}

resource "aws_subnet" "main"{
	vpc_id     = aws_vpc.my-deployment.id
	cidr_block = "10.20.1.0/24"
}

resource "aws_internet_gateway" "gateway"{
	vpc_id     = aws_vpc.my-deployment.id
}

# Gateway with routing table
resource "aws_route_table" "public-rt"{
	vpc_id     = aws_vpc.my-deployment.id
	 route {
	   cidr_block     = "0.0.0.0/0"
           gateway_id = aws_internet_gateway.gateway.id
        }
}

# Assign route table to subnet
resource "aws_route_table_association" "public-rt" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public-rt.id
}


# Worker security group
resource "aws_security_group" "cluster_sg" {
  name        = "worker_sgroup"
  description = "Allow certain inbound and all outbound traffic"
  vpc_id      = aws_vpc.my-deployment.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # Allow all tcp for Flask web server
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # allow all outbound traffic
    # this could be more secure . . .
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
