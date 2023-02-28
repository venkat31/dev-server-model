output "ec2-public-ip" {
    value = module.myapp-webserver.my-instance.public_ip
}