# iscdhcp::server::v4::pxe_server
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class.
#
# Type   Architecture Name
# ----   -----------------
#   0    Intel x86PC
#   1    NEC/PC98
#   2    EFI Itanium
#   3    DEC Alpha
#   4    Arc x86
#   5    Intel Lean Client
#   6    EFI IA32
#   7    EFI BC (EFI Byte Code)
#   8    EFI Xscale
#   9    EFI x86-64
#
# @example
# iscdhcp::server::pxe_server { 'namevar': }
#
# At this stage matching on vci is not supported, easy to implement however
# according to RFC 4578 in regards to option 93: "This option MUST be present
# in all DHCP and PXE packets sent by PXE-compliant clients and servers,
# making a match on vci redundant.
class iscdhcp::server::v4::pxe_server {

  assert_private()

  $next_server = $iscdhcp::server::v4::pxe_next_server
  $match_criteria = $iscdhcp::server::v4::pxe_match_criteria
  $arch_to_bootfile_map = $iscdhcp::server::v4::pxe_arch_to_bootfile_map
  $vci_to_bootfile_map = $iscdhcp::server::v4::pxe_vci_to_bootfile_map
  $default_bootfile = $iscdhcp::server::v4::pxe_default_bootfile
  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir

  if $match_criteria == 'vci' {
    fail("Matching on vci is not supported at this stage. Easy to implement however according to RFC 4578 in regards to option 93: `This \
  option MUST be present in all DHCP and PXE packets sent by PXE-compliant clients and servers` - making a match on vci redundant")
  }
  # have to add undef string as rspec-puppet passes symbol wrong
  if ($next_server == undef or $next_server == 'undef') {
    fail('if pxe_server is enabled, pxe_next_server must be set')
  }
  # have to add undef string as rspec-puppet passes symbol wrong
  if ($arch_to_bootfile_map == undef or $arch_to_bootfile_map == 'undef') {
    fail('if pxe_server is enabled, pxe_arch_to_bootfile_map must be set')
  }

  # do fail checks etc

  file { "${dhcp_dir}/enabled_services/v4/pxe_server.conf":
    ensure  => present,
    #owner  => 'root',
    #group  => $root_group,
    content => template('iscdhcp/server/v4/pxe_server.erb'),
    mode    => '0640',
  }
}
