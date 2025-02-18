resource "aws_key_pair" "key" {
  key_name   = "npci-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Change to your actual public key path
}

resource "aws_instance" "rke2_server" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t3.medium"
  subnet_id     = module.vpc.public_subnets[0]
  
  vpc_security_group_ids      = [aws_security_group.rke2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.key_name
  iam_instance_profile        = aws_iam_instance_profile.worker_profile.name
  
  root_block_device {
    volume_size = 20  # Set root volume size to 20GB
    volume_type = "gp3"  # General Purpose SSD volume type
  }

  tags = {
    Name = "RKE2-Master"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.rke2_config.rendered}' > rancher_config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/rancher/rke2",
      "sudo chmod 777 /etc/rancher/rke2",
      "sudo chown ubuntu /etc/rancher/rke2"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "./rancher_config.yaml"
    destination = "/etc/rancher/rke2/config.yaml"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y curl jq",
      "sudo snap install kubectl --classic",
      "curl -sfL https://get.rke2.io | sudo sh -",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service",
      "sleep 20",

      "sudo cat /var/lib/rancher/rke2/server/node-token | tee /tmp/rke2_token",
      "hostname -I | awk '{print $1}' | tee /tmp/rke2_server"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  depends_on = [ aws_eip.rancher ]
}


resource "aws_instance" "rke2_workers" {
  count         = 3
  ami           = "ami-0cb91c7de36eed2cb" 
  instance_type = "t3.medium"
  subnet_id     = module.vpc.public_subnets[(count.index + 3) % length(module.vpc.public_subnets)]

  vpc_security_group_ids      = [aws_security_group.rke2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.key_name
  iam_instance_profile        = aws_iam_instance_profile.worker_profile.name

  root_block_device {
    volume_size = 20  # Set root volume size to 20GB
    volume_type = "gp3"  # General Purpose SSD volume type
  }

  tags = {
    Name = "RKE2-Worker-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y curl jq",  # Ensure AWS CLI is installed
      "sudo apt install -y python3 python3-pip unzip",

      # Fetch RKE2 token & master IP from master node
      "TOKEN=$(ssh -o StrictHostKeyChecking=no ubuntu@${aws_instance.rke2_server.private_ip} 'cat /tmp/rke2_token')",
      "SERVER_IP=$(ssh -o StrictHostKeyChecking=no ubuntu@${aws_instance.rke2_server.private_ip} 'cat /tmp/rke2_server')",

      # Corrected: Explicitly setting RKE2 agent type before installation
      "curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE='agent' sh -",

      # Configure agent to join the master node
      "sudo mkdir -p /etc/rancher/rke2",
      "echo \"token: $TOKEN\" | sudo tee /etc/rancher/rke2/config.yaml",
      "echo \"server: https://$SERVER_IP:9345\" | sudo tee -a /etc/rancher/rke2/config.yaml",
      "echo \"cni: calico\"| sudo tee -a /etc/rancher/rke2/config.yaml",
      
      "sudo systemctl enable rke2-agent.service",
      "sudo systemctl start rke2-agent.service"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  depends_on = [ aws_instance.rke2_server , aws_eip_association.eip_assoc]
}
