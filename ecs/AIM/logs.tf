# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "AIM_log_group" {
  name              = "/ecs/AIM_logs"
  retention_in_days = 1

  tags = {
    Name = "AIM-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "AIM_log_stream" {
  name           = "AIM-log-stream"
  log_group_name = aws_cloudwatch_log_group.AIM_log_group.name
}

