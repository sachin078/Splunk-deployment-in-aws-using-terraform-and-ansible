
# Simplifying Splunk Deployment on AWS with Terraform and Ansible 🚀

## Introduction:
In today's data-driven world, effective log management and analysis are essential for maintaining the security and integrity of IT infrastructure. Splunk Enterprise is a powerful platform that enables organizations to gain valuable insights from their machine-generated data. However, deploying Splunk can be complex, especially in cloud environments like AWS. In this guide, we'll walk you through the process of setting up Splunk Enterprise on AWS using Terraform and Ansible, streamlining the deployment and configuration process.

## Prerequisites:
Before diving into the deployment process, ensure you have the following prerequisites:
- An AWS account with appropriate permissions.
- Terraform installed on your local machine.
- Basic understanding of AWS services and Terraform concepts.
- Access to the Splunk Enterprise installation package. 🔑

## Step 1: Provisioning AWS Resources and install Splunk with Terraform:
We'll start by defining the infrastructure requirements using Terraform. Below is an example Terraform configuration file (`main.tf`) that provisions an AWS EC2 instance, installs Splunk Enterprise, copies the Ansible playbook to the Splunk server, and executes them. 

```hcl
resource "aws_instance" "testsplunk" {
  ami                    = "your AMI ID"
  instance_type          = "t2.medium"
  key_name               = "your key Id"
  security_groups        = ["ID of Security group"]
  subnet_id              = "ID of subnet"

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = 60
    volume_type           = "your volume type"
    delete_on_termination = true
  }

  tags = {
    Name = "splunk-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y wget",
      "wget -O splunk-your version -78803f08xxxxx-linux-2.6-amd64.deb 'https://download.splunk.com/products/splunk/releases/9.0.1/linux/splunk-9.x.x-7880xxxxxxx-linux-2.6-amd64.deb'",
      "sudo dpkg -i splunk-9.x.x-78803f08aabb-linux-2.6-amd64.deb",
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
```


In this task, you are required to substitute the path to the private key stored in AWS, as well as the path to your Ansible playbooks for creating an alert and enabling log from a source. Additionally, you can modify the destination path on the remote Splunk server to accommodate your preferences.

It is crucial to verify that there is ample storage allocated for Splunk to operate smoothly, ensuring it is attached to the root partition, typically identified as `/dev/sda1` in most cases.

## Step 2: Configuring Log source to Splunk with Ansible:
Once the EC2 instance is provisioned, we'll use Ansible to automate the log source configuration of Splunk. The following Ansible playbook demonstrates how to install Splunk, configure log sources, and set up alerts.

```yaml
- name: log sources in Splunk
 hosts: 127.0.0.1
 become: yes
 tasks:
 - name: Fetch syslog and auth.log from current machine
 ansible.builtin.fetch:
 src: /var/log/syslog
 dest: /tmp/syslog
- name: Fetch auth.log from current machine
 ansible.builtin.fetch:
 src: /var/log/auth.log
 dest: /tmp/auth.log
- name: Copy inputs.conf file
 ansible.builtin.copy:
 content: |
 [monitor:///tmp/syslog]
 disabled = false
 index = main
 sourcetype = syslog
[monitor:///tmp/auth.log]
 disabled = false
 index = main
 sourcetype = auth
 dest: /opt/splunk/etc/system/local/inputs.conf
- name: Restart Splunk service
 ansible.builtin.service:
 name: splunk
 state: restarted
```

## Step 3: Verifying Splunk Configuration:
After the deployment, it's crucial to verify that Splunk is properly installed and configured. You can use the following Ansible playbook to check Splunk status.

```yaml
- name: Verify Splunk
 hosts: all
 become: yes
 tasks:
 - name: Verifying if Splunk is installed
 ansible.builtin.command: /opt/splunk/bin/splunk
 register: splunk_status
 ignore_errors: true
- name: Print Splunk status
 ansible.builtin.debug:
 msg: "Splunk is {{ 'installed' if splunk_status.rc == 0 else 'not installed' }}"
```

## Step 4: Log Ingestion Configuration:
Splunk relies on data ingestion from various sources. We'll configure Splunk to monitor system logs by fetching syslog and auth.log from the EC2 instance.

```conf
[monitor:///tmp/syslog]
disabled = false
index = main
sourcetype = syslog
[monitor:///tmp/auth.log]
disabled = false
index = main
sourcetype = auth
```

## Step 5: Setting Up Alerts:
Alerting plays a vital role in detecting and responding to potential security threats. We'll create a simple alert script and schedule it to run periodically.

```yaml
- name: Brute Force Alert 
 hosts: 127.0.0.1
 become: yes
 tasks:
 - name: Alert script
 ansible.builtin.copy:
 content: |
 #!/bin/bash
 echo "Alert: Unauthorized access detected" | /opt/splunk/bin/splunk add data-to-index -index main -sourcetype alert
 dest: /opt/splunk/bin/alert_script.sh
 mode: "0755"
 -name: Schedule alert execution
 ansible.builtin.cron:
 name: "Splunk Unauthorized Access Alert"
 minute: "*/5"
 job: "/opt/splunk/bin/alertscript.sh"
```

## Conclusion:
By leveraging Terraform and Ansible, deploying Splunk Enterprise on AWS becomes a seamless and repeatable process. This automated approach not only saves time but also ensures consistency and reliability in your Splunk deployment. With Splunk up and running, organizations can harness the power of their machine-generated data to drive informed decision-making and enhance security posture. 🌟

## Article: https://medium.com/@sachin05prabakar/simplifying-splunk-deployment-on-aws-with-terraform-and-ansible-2a47ddb69f32
