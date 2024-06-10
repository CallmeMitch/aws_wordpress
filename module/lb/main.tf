
## Ressource autobalancer
resource "aws_lb" "load_balancer_wordpress" {
  //count              = 3
  name               = "LoadBalancerValentinBrison"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.aws_loadbalancer_sg_id]
  subnets            = var.public_subnet
}


## Create rule for listen within vpc on "80" port

resource "aws_lb_target_group" "private_application_tg" {
  name     = "EC2--Target-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "wordpress" {
  count = 3
  autoscaling_group_name = element(var.autoscaling_group_name, count.index)
  lb_target_group_arn    = aws_lb_target_group.private_application_tg.arn
}

resource "aws_lb_listener" "listener" {
  //count = 3
  load_balancer_arn = aws_lb.load_balancer_wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_application_tg.arn
  }
}