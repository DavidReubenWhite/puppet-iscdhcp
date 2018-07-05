# iscdhcp::server::v4::subnet
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::v4::subnet { 'namevar': }
define iscdhcp::server::v4::subnet (
  Optional[Hash]    $parameters = undef,
  Optional[Hash]    $options = undef,
  Optional[Hash]    $actions = undef,
  Optional[Hash]    $hosts = undef,
  Optional[String]  $shared_network = undef,
  Optional[Boolean] $authoritative = undef,
  Optional[String]  $failover_peer = undef,
  String            $dhcp_dir = $iscdhcp::server::v4::dhcp_dir,
) {

  assert_private()

  # figure out how to enable this without breaking rspec-puppet without including base class

  # if !(defined(Class['iscdhcp::server::v4'])) {
  #   fail('You must include a v4 server before using any defined resources')
  # }

  # should really have merged the subnet defaults in here...

  if $hosts {
    $hosts.each | $host, $values | {
      if has_key($values, 'parameters') {
        if has_key($values['parameters'], 'host-identifier') {
          unless (has_key($values['parameters']['host-identifier'],'option')
            and has_key($values['parameters']['host-identifier'], 'value')) {
            fail('if host-identifier specified, must contain an option and value')
          }
        }
      }
    }
  }

  if $shared_network {
    concat::fragment { "${title}_subnet":
      target  => "${dhcp_dir}/networks/v4/${shared_network}.conf",
      content => template('iscdhcp/subnet.erb'),
      order   => 2,
    }
  }
  else {
    concat::fragment { "${title}_subnet":
      target  => "${dhcp_dir}/networks/v4/_private.conf",
      content => template('iscdhcp/subnet.erb'),
      order   => 2,
    }
  }
}
