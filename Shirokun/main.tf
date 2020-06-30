provider "aws" {
	region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami = "ami-f90a4880"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "{"health":"ok"}" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags {
    Name = "terraform-exam"
  }

	key_name = "terraform-key"

provisioner "remote-exec" {
	inline = [
		"sudo amazon-linux-extras enable nginx1.12",
		"sudo yum -y install nginx",
		"sudo systemctl start nginx"
		]
	}
}

resource "aws_security_group" "instance" {
  name = "terraform-exam-instance"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}" 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "Server port for HTTP requests"
  default = 8080
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}

