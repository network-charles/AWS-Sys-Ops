output "EC2" {
  value = "ssh -i 'hi.pem' ubuntu@${data.aws_instance.one.public_ip}"
}
