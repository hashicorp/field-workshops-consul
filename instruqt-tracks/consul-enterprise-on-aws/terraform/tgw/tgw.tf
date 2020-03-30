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

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-api-tgw-attachment" {
  subnet_ids         = flatten([data.terraform_remote_state.vpc.outputs.api_private_subnets])
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = data.terraform_remote_state.vpc.outputs.api_vpc
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

resource "aws_route" "vpc-shared-svcs-api-route" {
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

resource "aws_route" "vpc-frontend-api-route" {
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

// API TGW Routes
resource "aws_route" "vpc-api-shared-svc-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids, count.index)
  destination_cidr_block = "10.1.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-api-frontend-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids, count.index)
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "vpc-api-storage-route" {
  count                  = length(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids)
  route_table_id         = element(data.terraform_remote_state.vpc.outputs.api_private_route_table_ids, count.index)
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
