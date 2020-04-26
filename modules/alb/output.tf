output "lb_arn" {
  value = aws_lb.main.arn
}

output "listener_arn_https" {
  value = aws_lb_listener.https.arn
}

output "target_group_arn_default" {
  value = aws_lb_target_group.https_default.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}
