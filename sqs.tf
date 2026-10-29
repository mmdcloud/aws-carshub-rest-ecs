# -----------------------------------------------------------------------------------------
# SQS Config
# -----------------------------------------------------------------------------------------
resource "aws_lambda_event_source_mapping" "sqs_event_trigger" {
  event_source_arn                   = module.carshub_media_events_queue.arn
  function_name                      = module.carshub_media_update_function.arn
  enabled                            = true
  batch_size                         = 10
  maximum_batching_window_in_seconds = 60
}

# SQS Queue for buffering S3 events
module "carshub_media_events_queue" {
  source                     = "../../../modules/sqs"
  queue_name                 = "carshub-media-events-queue-${var.env}-${var.region}"
  delay_seconds              = 0
  maxReceiveCount            = 3
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 180
  receive_wait_time_seconds  = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = "arn:aws:sqs:${var.region}:*:carshub-media-events-queue-${var.env}-${var.region}"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = module.carshub_media_bucket.arn
          }
        }
      }
    ]
  })
  tags = {
    Name        = "carshub-media-events-queue-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

module "carshub_media_events_dlq" {
  source                     = "../../../modules/sqs"
  queue_name                 = "carshub-media-events-dlq-${var.env}-${var.region}"
  delay_seconds              = 0
  maxReceiveCount            = 3
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 180
  receive_wait_time_seconds  = 20
  policy                     = ""
  tags = {
    Name        = "carshub-media-events-dlq-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}