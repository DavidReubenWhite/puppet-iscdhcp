# iscdhcp::server::v4::service
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v4::service
class iscdhcp::server::v4::service {

  assert_private()

  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir
  $service_name = $iscdhcp::server::v4::service_name

  # exec { "test ${service_name} config":
  #   command     => "/usr/sbin/${service_name} -cf ${dhcp_dir}/dhcpd.conf -t",
  #   provider    => shell,
  #   refreshonly => true,
  # }
  # ~> service { $service_name:
  #   ensure => running,
  #   enable => true,
  # }
}
