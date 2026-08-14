output "arn_kvs_telemetry"{
    value = aws_kinesis_stream.data_stream.arn
}

output "name_kvs_telemetry"{
    value = aws_kinesis_stream.data_stream.name
}