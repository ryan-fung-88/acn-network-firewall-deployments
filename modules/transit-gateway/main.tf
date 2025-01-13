resource "aws_ec2_transit_gateway" "this_tgw" {
  count = var.create_tgw ? 1 : 0

  auto_accept_shared_attachments = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  description = var.tgw_description
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attach" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this_tgw.id
  vpc_id = each.value.vpc_id
  subnet_ids = each.value.subnet_ids
  dns_support = each.value.dns_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation
}

