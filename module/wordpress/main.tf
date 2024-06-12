resource "aws_launch_template" "valentin_launch_template" {
  name                  = "valentinbrisonadministator"
  user_data             = filebase64("/home/jonas801/Bureau/TECHNIQUE/aws_wordpress/module/wordpress/cloud-init/wordpress.sh")
  instance_type         = "t2.micro"
  image_id              = "ami-0c68b55d1c875067e"
  depends_on            = [ var.aws_db_instance ]
}

### Ressource pour l'autoscaling

resource "aws_autoscaling_group" "autoscaling_wordpress" {
  count                = 3
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  
  vpc_zone_identifier  = var.private_subnet
  name                 = "WP_AutoScalingGroup${count.index}"

  launch_template {
    id      = aws_launch_template.valentin_launch_template.id
    version = aws_launch_template.valentin_launch_template.latest_version
  }
}

resource "aws_iam_role_policy" "test_policy" {
  name = "valentin_brison_instance_wordpress_policy"
  role = "${aws_iam_role.valentin_role_instance.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "valentin_profile" {
  name = "valentin_brison_profile"
  role = "${aws_iam_role.valentin_role_instance.name}"
}


resource "aws_iam_role" "valentin_role_instance" {
  name = "valentin_role_instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}