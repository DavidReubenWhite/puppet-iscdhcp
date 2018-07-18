# iscdhcp::server::v4::failover
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::v4::failover { 'namevar': }
class iscdhcp::server::v4::failover {

  assert_private()

  $role = $iscdhcp::server::v4::failover_role
  $listen_port = $iscdhcp::server::v4::failover_listen_port
  $peer_port = $iscdhcp::server::v4::failover_peer_port
  $listen_address = $iscdhcp::server::v4::failover_listen_address
  $peer_address = $iscdhcp::server::v4::failover_peer_address
  $max_response_delay = $iscdhcp::server::v4::failover_max_response_delay
  $max_unacked_updates = $iscdhcp::server::v4::failover_max_unacked_updates
  $mclt = $iscdhcp::server::v4::failover_mclt
  $split = $iscdhcp::server::v4::failover_split
  $load_balance_max_s = $iscdhcp::server::v4::failover_load_balance_max_s
  $failover_name = $iscdhcp::server::v4::failover_name

  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir
  $pools_failover_name = $iscdhcp::server::v4::config::failover_names[0]

  if ($failover_name == undef or $failover_name == 'undef'){
    fail('if failover enabled, failover_name must be set')
  }
  # Assuming that the dhcp server will run with a dhcp failover name but nothing specified on the pools. Need to verify this.
  if (!empty($pools_failover_name) and ($failover_name != $pools_failover_name)) {
    fail('if failover enabled, failover_name must match name specified on subnet pool')
  }

  file { "${dhcp_dir}/enabled_services/v4/failover.conf":
    ensure  => present,
    #owner  => 'root',
    #group  => $root_group,
    content => template('iscdhcp/server/v4/failover.erb'),
    mode    => '0640',
  }
}
