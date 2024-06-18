# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-shared-svcs-tgw-attachment" {
  subnet_ids         = flatten([data.terraform_remote_state.vpc.outputs.shared_svcs_private_subnets])
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.terraform_remote_state.vpc.outputs.shared_svcs_vpc
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-frontend-tgw-attachment" {
  subnet_ids         = flatten([data.terraform_remote_state.vpc.outputs.frontend_private_subnets])
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.terraform_remote_state.vpc.outputs.frontend_vpc
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-backend-tgw-attachment" {
  subnet_ids         = flatten([data.terraform_remote_state.vpc.outputs.backend_private_subnets])
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.terraform_remote_state.vpc.outputs.backend_vpc
}

/*
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-storage-attachment" {
  subnet_ids         = flatten([data.terraform_remote_state.vpc.outputs.vpc-storage.private_subnets])
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc-storage.vpc_id
}
*/

// Shared Svcs TGW Routes
resource "aws_route" "vpc-shared-svcs-frontend-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids, count.index)
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-shared-svcs-backend-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids, count.index)
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-shared-svcs-storage-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.shared_svcs_private_route_table_ids, count.index)
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

// Frontend TGW Routes
resource "aws_route" "vpc-frontend-shared-svc-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids, count.index)
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-frontend-backend-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids, count.index)
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-frontend-storage-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.frontend_private_route_table_ids, count.index)
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

// backend TGW Routes
resource "aws_route" "vpc-backend-shared-svc-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids, count.index)
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-backend-frontend-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids, count.index)
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-backend-storage-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.backend_private_route_table_ids, count.index)
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
