# SQS queue to receive S3 events
resource "aws_sqs_queue" "queue" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  policy                     = var.policy
  redrive_policy = var.dead_letter_target_arn != null ? jsonencode({
    deadLetterTargetArn = var.dead_letter_target_arn
    maxReceiveCount     = var.maxReceiveCount != null && var.maxReceiveCount != "" ? tonumber(var.maxReceiveCount) : 3
  }) : null
  tags = merge(
    {
      Name = var.queue_name
    },
    var.tags
  )
}