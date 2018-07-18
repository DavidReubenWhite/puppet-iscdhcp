# iscdhcp::server::omapi_listener
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::omapi_listener { 'namevar': }
class iscdhcp::server::v4::omapi_listener {

  assert_private()

  $omapi_port = $iscdhcp::server::v4::omapi_port
  $omapi_key_name = $iscdhcp::server::v4::omapi_key_name
  $omapi_algorithm = $iscdhcp::server::v4::omapi_algorithm
  $omapi_secret = $iscdhcp::server::v4::omapi_secret
  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir

  # have to add undef string as rspec-puppet passes symbol wrong
  if $omapi_key_name == undef or $omapi_key_name == 'undef' {
    fail('if an omapi listener is enabled `omapi_key_name` must be set')
  }
  if $omapi_secret == undef or $omapi_secret == 'undef' {
    fail('if an omapi listener is enabled `omapi_secret` must be set')
  }
  file { "${dhcp_dir}/enabled_services/v4/omapi_listener.conf":
    ensure  => present,
    #owner  => 'root',
    #group  => $root_group,
    content => template('iscdhcp/server/v4/omapi_listener.erb'),
    mode    => '0640',
  }
}
