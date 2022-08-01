# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "vegafoodies_log_group" {
  name              = "/ecs/vegafoodies"
  retention_in_days = 1

  tags = {
    Name = "vegafoodies-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "vegafoodies_log_stream" {
  name           = "vegafoodies-log-group"
  log_group_name = aws_cloudwatch_log_group.vegafoodies_log_group.name
}

