# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v6::service
class iscdhcp::server::v6::service {

  assert_private()

  $dhcp_dir = lookup('iscdhcp::server::dhcp_dir')
  $service_name = lookup('iscdhcp::server::service_name')

  exec { "test ${service_name} config":
    command     => "/usr/sbin/${service_name} -cf ${dhcp_dir}/dhcpd.conf -t",
    provider    => shell,
    refreshonly => true,
  }
  ~> service { $service_name:
    ensure => running,
    enable => true,
  }
}
