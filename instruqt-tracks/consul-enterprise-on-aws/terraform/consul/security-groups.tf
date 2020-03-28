resource "aws_security_group" "consul_lb_external" {
  vpc_id = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "consul_ssh" {
  name        = "consul-ssh"
  description = "Allow ssh traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consul_lb" {
  name        = "consul-lb"
  description = "Allow lb traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc

  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    security_groups = [aws_security_group.consul_lb_external.id]
  }
}
