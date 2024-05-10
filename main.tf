resource "aws_instance" "testsplunk" {
  ami                    = "ami-0e001c9271cf7f3b9"
  instance_type          = "t2.medium"
  key_name               = "your key Id"
  security_groups        = ["ID of Security group"]
  subnet_id              = "ID of subnet"

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
      "wget -O splunk-your version -78803f08xxxxx-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/9.0.1/linux/splunk-9.0.1-78803f08aabb-linux-2.6-amd64.deb'",
      "sudo dpkg -i splunk-9.0.1-78803f08aabb-linux-2.6-amd64.deb",
      "sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd yourpassword",
      "sudo /opt/splunk/bin/splunk status",
      "sudo /opt/splunk/bin/splunk enable boot-start -user splunk",
      "sudo /opt/splunk/bin/splunk restart",
      "sudo /opt/splunk/bin/splunk status"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("path to your private key")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "path to your splunk verification/install_splunk.yml"
    destination = "/tmp/install_splunk.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("path to your private key")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "path to your inputs/inputs.conf"
    destination = "/tmp/inputs.conf"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("path to your private key")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "path to your log source config/configure_log_sources.yml"
    destination = "/tmp/configure_log_sources.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("path to your private key")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "path to your alert config file/configure_alerts.yml"
    destination = "/tmp/configure_alerts.yml"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/path to your private key")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "path to your log file /access.log"
    destination = "/tmp/access.log"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("path to your private key")
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
      private_key = file("path to your private key")
      host        = self.public_ip
    }
  }
}
