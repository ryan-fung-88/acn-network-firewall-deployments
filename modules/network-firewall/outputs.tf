output "nfw_endpoint" {
  value = aws_networkfirewall_firewall.this_network_firewall.firewall_status[0].sync_states[*].attachment[0].endpoint_id
}