resource "aws_instance" "testsplunk" {
  ami                    = "ami-0e001c9271cf7f3b9"
  instance_type          = "t2.medium"
  key_name               = "p1"
  security_groups        = ["sg-06c712d8c78c8c20a"]
  subnet_id              = "subnet-b62e3ffc"

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 60
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "splunk-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y wget",
      "wget -O splunk-9.2.1-78803f08aabb-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/9.2.1/linux/splunk-9.2.1-78803f08aabb-linux-2.6-amd64.deb'",
      "sudo dpkg -i splunk-9.2.1-78803f08aabb-linux-2.6-amd64.deb",
      "sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd sachin12345678",
      "sudo /opt/splunk/bin/splunk status",
      "sudo /opt/splunk/bin/splunk enable boot-start -user splunk",
      "sudo /opt/splunk/bin/splunk restart",
      "sudo /opt/splunk/bin/splunk status"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "/Users/sachin/Desktop/MASTER/gitproject/TerraForm/Ter/install_splunk.yml"
    destination = "/tmp/install_splunk.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "/Users/sachin/Desktop/MASTER/gitproject/TerraForm/Ter/files/inputs.conf"
    destination = "/tmp/inputs.conf"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "/Users/sachin/Desktop/MASTER/gitproject/TerraForm/Ter/configure_log_sources.yml"
    destination = "/tmp/configure_log_sources.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "/Users/sachin/Desktop/MASTER/gitproject/TerraForm/Ter/configure_alerts.yml"
    destination = "/tmp/configure_alerts.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "/Users/sachin/Desktop/MASTER/gitproject/TerraForm/access.log"
    destination = "/tmp/access.log"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ansible",
      "ansible-playbook /tmp/install_splunk.yml",
      "ansible-playbook /tmp/configure_log_sources.yml",
      "ansible-playbook /tmp/configure_alerts.yml"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/sachin/Downloads/p1.pem")
      host        = self.public_ip
    }
  }
}
