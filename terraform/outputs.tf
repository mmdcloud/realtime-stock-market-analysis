output "kafka_instnace_ip" {
  value = aws_instance.kafka_instance.public_ip
}
