# SQS queue to receive S3 events
resource "aws_sqs_queue" "queue" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # Optional: Add a DLQ for failed messages
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue.arn
    maxReceiveCount     = 5
  })
}

# Dead Letter Queue for failed messages
resource "aws_sqs_queue" "dlq" {
  name                      = var.dlq_name
  message_retention_seconds = var.message_retention_seconds
}
