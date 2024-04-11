# # Create ASG security group
resource "aws_security_group" "chat_asg_sg" {
  name        = "chat-asg-sg"
  description = "Allow HTTP traffic from ALB"
  vpc_id      = aws_vpc.chat_vpc.id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Attach outbound rule for ec2 instances that allow outbound traffic from ec2 to anywhere 
# resource "aws_security_group_rule" "alb_asg_to_vpc_endpoint" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   security_group_id = aws_security_group.chat_asg_sg.id
#   source_security_group_id = aws_security_group.chat_vpc_endpoint_sg.id
# }

# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2_webui_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRole"
        ],
        "Principal": {
          "Service": [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# Attach ECR Readonly Access in order to be able access API & pull images
resource "aws_iam_role_policy_attachment" "test_role_ecr_read_only" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach S3 Readonly Acccess in roder to allow to pull actual image data from S3
resource "aws_iam_role_policy_attachment" "test_role_s3_read_only" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "chat_ec2_instances_profile" {
  name = "chat-ec2-instances-profile"
  role = aws_iam_role.ec2_iam_role.name
}

# Create launch template for autoscaling group
resource "aws_launch_template" "chat_asg_launch_template" {
	update_default_version = true
  name_prefix   = "chat-webui-launch-template-"
  instance_type = "t4g.nano"
  image_id      = "ami-06ea60c08bdaa1f49"
  user_data     = filebase64("./user-data.sh") 
  vpc_security_group_ids  = [aws_security_group.chat_asg_sg.id]

  iam_instance_profile {
    name = "chat-ec2-instances-profile"
  }
}

resource "aws_autoscaling_group" "chat_asg" {
	name = "chat-webui-asg"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

	vpc_zone_identifier = [
    aws_subnet.chat_private_subnet_a.id,
    aws_subnet.chat_private_subnet_b.id
  ]

  launch_template {
    id      = aws_launch_template.chat_asg_launch_template.id
    version = "$Latest"
  }

  // should waint untill first image will be pushed to ecr repository
  depends_on = [ null_resource.build_and_push_docker_image ]
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "autoscaling_groupz_attachment" {
  autoscaling_group_name = aws_autoscaling_group.chat_asg.id
  lb_target_group_arn    = aws_lb_target_group.chat_lb_target_group.arn
}