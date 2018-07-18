# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v4::freeform_input
class iscdhcp::server::v4::freeform_input {
  $input = $iscdhcp::server::v4::freeform_input
  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir

  file { "${dhcp_dir}/enabled_services/v4/freeform_input.conf":
    ensure  => present,
    #owner  => 'root',
    #group  => $root_group,
    content => $input,
    mode    => '0640',
  }
}
