locals {
  # List of maps with key and route values
  vpc_attachments_with_routes = chunklist(flatten([
    for k, v in var.vpc_attachments : setproduct([{ key = k }], v.tgw_routes) if var.create_tgw && can(v.tgw_routes)
  ]), 2)

  tgw_default_route_table_tags_merged = merge(
    var.tags,
    { Name = var.name },
    var.tgw_default_route_table_tags,
  )

  vpc_route_table_destination_cidr = flatten([
    for k, v in var.vpc_attachments : [
      for rtb_id in try(v.vpc_route_table_ids, []) : {
        rtb_id = rtb_id
        cidr   = v.tgw_destination_cidr
        tgw_id = var.create_tgw ? aws_ec2_transit_gateway.this_tgw[0].id : v.tgw_id
      }
    ]
  ])
}

resource "aws_ec2_transit_gateway" "this_tgw" {
  count = var.create_tgw ? 1 : 0

  auto_accept_shared_attachments = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  description = var.tgw_description
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attach" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this_tgw[0].id
  vpc_id = each.value.vpc_id
  subnet_ids = each.value.subnet_ids
  dns_support = each.value.dns_support
  transit_gateway_default_route_table_association = each.value.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = each.value.transit_gateway_default_route_table_propagation
}

################################################################################
# Route Table / Routes
################################################################################

resource "aws_ec2_transit_gateway_route_table" "this" {
  count = var.create_tgw && var.create_tgw_routes ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.this_tgw[0].id

  tags = merge(
    var.tags,
    { Name = var.name },
    var.tgw_route_table_tags,
  )
}

resource "aws_route" "this" {
  for_each = { for x in local.vpc_route_table_destination_cidr : x.rtb_id => {
    cidr   = x.cidr,
    tgw_id = x.tgw_id
  } }

  route_table_id              = each.key
  destination_cidr_block      = "0.0.0.0/0"
  destination_ipv6_cidr_block =  null
  transit_gateway_id          = each.value["tgw_id"]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = {
    for k, v in var.vpc_attachments : k => v if var.create_tgw && var.create_tgw_routes && try(v.transit_gateway_default_route_table_association, true) != true
  }

  # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attach[each.key].id
  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = {
    for k, v in var.vpc_attachments : k => v if var.create_tgw && var.create_tgw_routes && try(v.transit_gateway_default_route_table_propagation, true) != true
  }

  # Create association if it was not set already by aws_ec2_transit_gateway_vpc_attachment resource
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attach[each.key].id
  transit_gateway_route_table_id = var.create_tgw ? aws_ec2_transit_gateway_route_table.this[0].id : try(each.value.transit_gateway_route_table_id, var.transit_gateway_route_table_id)
}