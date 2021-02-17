output "NewSubsURL" {
  description = "URL for new submissions"
  value       = aws_route53_record.IntDNSAlias.name
}