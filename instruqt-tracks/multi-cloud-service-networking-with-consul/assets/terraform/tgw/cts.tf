resource "aws_instance" "cts" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = "t3.small"
    key_name                    = data.terraform_remote_state.infra.outputs.aws_ssh_key_name
    vpc_security_group_ids      = [aws_security_group.consul.id]
    subnet_id                   = data.terraform_remote_state.infra.outputs.aws_shared_svcs_public_subnets[0]
    associate_public_ip_address = true
    tags = {
      Name = "cts-hrs"
    }
    user_data                   = data.template_file.init_cts.rendered
    iam_instance_profile        = aws_iam_instance_profile.cts_iam.name

    provisioner "file" {
      source      = "security_input.tfvars"
      destination = "/home/ubuntu/security_input.tfvars"
      
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }
  }
}

data "template_file" "init_cts" {
  template = file("${path.module}/scripts/cts-043.sh")
  vars = {
    env = data.terraform_remote_state.infra.outputs.env
  }
}
