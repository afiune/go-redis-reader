output "ubuntu_public_ip" {
  value = "${aws_instance.ubuntu1804.*.public_ip}"
}
