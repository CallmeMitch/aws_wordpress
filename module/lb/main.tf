
## Ressource autobalancer
resource "aws_lb" "load_balancer_wordpress" {
  count              = 3
  name               = "LoadBalancerValentinBrison"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.aws_loadbalancer_sg_id]
  subnets            = [var.public_subnet[count.index]]
}


### Ressource pour l'autoscaling

resource "aws_autoscaling_group" "autoscaling_wordpress" {
  count                = 3
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  #launch_configuration = aws_launch_configuration.wordpress_ec2.name
  vpc_zone_identifier  = var.private_subnet[count.index]
  name                 = "WP_AutoScalingGroup"
}


## Create rule for listen within vpc on "80" port

resource "aws_lb_target_group" "private_application_tg" {
  name     = "EC2--Target-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "wordpress" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_wordpress.id
  lb_target_group_arn    = aws_lb_target_group.private_application_tg.arn
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer_wordpress[count.index].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_application_tg.arn
  }
}