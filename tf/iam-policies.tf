resource "aws_iam_policy" "ecr_readonly" {
  name        = "ECRReadOnlyPolicy"
  description = "Allows worker nodes to pull images from ECR"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_attach" {
  policy_arn = aws_iam_policy.ecr_readonly.arn
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ebscsi_attach" {
  role       = aws_iam_role.worker_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "worker_node_role" {
  name = "worker-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "worker-instance-profile"
  role = aws_iam_role.worker_node_role.name
}
