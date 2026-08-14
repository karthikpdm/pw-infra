resource "aws_kinesis_stream" "data_stream" {
  name             = "pw-data-stream" 
  shard_count      = 1
  retention_period = 168
  encryption_type  = "KMS"
  kms_key_id       = "alias/aws/kinesis"

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = var.tags
}

# Kinesis Video Stream resource
resource "aws_kinesis_video_stream" "video_stream" {
  name                    = "pw-video-stream"
  data_retention_in_hours = 8760
  # device_name             = "kinesis-video-device-name"
  # media_type              = "video/h264"

  tags = var.tags
}