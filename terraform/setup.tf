# create a new redshift cluster in aws.
resource "aws_redshift_cluster" "redshift" {
  cluster_identifier = "redshift-cluster-pipeline"
  skip_final_snapshot = true # must be set so we can destroy redshift with terraform destroy
  master_username    = "redshiftcluster"
  master_password    = "Dawood308"
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  publicly_accessible = "true"
  iam_roles = [aws_iam_role.redshift_role.arn]
  vpc_security_group_ids = [aws_security_group.sg1_redshift.id]
}

# Confuge security group for Redshift allowing all inbound/outbound traffic
 resource "aws_security_group" "sg1_redshift" {
  name        = "sg_redshift"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Create S3 Read only access role. This is assigned to Redshift cluster so that it can read data from S3
resource "aws_iam_role" "redshift_role" {
  name = "RedShiftLoadRole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })
}

# Create S3 bucket
resource "aws_s3_bucket" "redditbucket308" {
  bucket = "redditbucket308"
  force_destroy = true # will delete contents of bucket when we run terraform destroy
}

# Set access control of bucket to private
resource "aws_s3_bucket_acl" "s3_redditbucket308_acl" {
  bucket = "redditbucket308"
  acl    = "private"
}