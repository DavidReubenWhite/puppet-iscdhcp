# iscdhcp::server::v4::config
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v4::config
class iscdhcp::server::v4::config {

  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir
  $root_group = $iscdhcp::server::v4::root_group
  $global_defaults = $iscdhcp::server::v4::global_defaults
  $subnet_defaults = $iscdhcp::server::v4::subnet_defaults
  $subnets = $iscdhcp::server::v4::subnets
  $enabled_services = $iscdhcp::server::v4::enabled_services
  $service_name = $iscdhcp::server::v4::service_name

  assert_private()

  $networks = iscdhcp::get_shared_networks($subnets)

  # make sure that there is only 1 failover peer specified across all pools.
  $failover_names = iscdhcp::failover_names($subnets)
  if length($failover_names) > 1 {
    fail("can only have one unique failover peer, got: ${failover_names}")
  }
  elsif length($failover_names) == 0 and ('failover' in $enabled_services) {
    fail('if failover enabled, must be declared per pool')
  }

  # file { '/usr/lib/systemd/system/dhcpd.service':
  #   source => 'puppet:///modules/tpdhcp/dhcpd.service',
  #   owner  => 'root',
  #   group  => 'root',
  #   mode   => '0644',
  #   notify => Exec['systemctl-daemon-reload'],
  # }

  file {[
          "${dhcp_dir}/networks",
          "${dhcp_dir}/networks/v4",
          "${dhcp_dir}/enabled_services",
        ]:
    ensure => 'directory',
    purge  => true,
  }
  concat { "${dhcp_dir}/dhcpd.conf":
    ensure => present,
    owner  => 'root',
    group  => $root_group,
    order  => 'numeric',
    mode   => '0640',
    notify => Exec["test ${service_name} config"],
  }

  # CONCAT ORDER
  # 1 = HEADER
  # 2 = ENABLED SERVICES INCLUDES
  # 3 = GLOBAL DEFAULTS
  # 4 = NETWORK INCLUDES


  # subnets go in their own file based on shared network name

  concat::fragment { "${dhcp_dir}/dhcpd.conf_header":
    target  => "${dhcp_dir}/dhcpd.conf",
    content => template('iscdhcp/header.erb'),
    order   => 1,
  }

  $enabled_services.each | Integer $index, String $service | {
    class { "iscdhcp::server::v4::${service}": }
    # if it's the last enabled service to include - add an extra \n
    if ($index + 1) != length($enabled_services) {
      $content = {
        'content' => "include \"${dhcp_dir}/enabled_services/${service}.conf\";\n"
      }
    }
    else {
      $content = {
        'content' => "include \"${dhcp_dir}/enabled_services/${service}.conf\";\n\n"
      }
    }
    # put the index as the first dynamic part of fragment name to break tie for ordering
    concat::fragment { "${dhcp_dir}/dhcpd.conf_${index}_${service}":
      target => "${dhcp_dir}/dhcpd.conf",
      *      => $content,
      order  => 2,
    }
  }

  if $global_defaults {
    concat::fragment { "${dhcp_dir}/dhcpd.conf_global_defaults":
      target  => "${dhcp_dir}/dhcpd.conf",
      content => template('iscdhcp/global_defaults.erb'),
      order   => 3,
    }
  }
  # each shared network goes in its own file (including no shared network)
  $networks.each | $shared_network, $subnets | {
    concat { "${dhcp_dir}/networks/v4/${shared_network}.conf":
      ensure => present,
      owner  => 'root',
      group  => $root_group,
      order  => 'numeric',
      mode   => '0640',
      notify => Exec["test ${service_name} config"],
    }
    # for each shared network we need the below extra statements to wrap around the subnets.
    if !($shared_network == '_private') {
      concat::fragment { "${shared_network}.conf_header":
        target  => "${dhcp_dir}/networks/v4/${shared_network}.conf",
        content => "shared-network \"${shared_network}\" {\n",
        order   => 1,
      }
      concat::fragment { "${shared_network}.conf_footer":
        target  => "${dhcp_dir}/networks/v4/${shared_network}.conf",
        content => "}\n",
        order   => 3,
      }
    }
    # to merge the subnet defaults in at the correct nesting level as the merge that create_resources does is only one level.
    $merged_subnets = $subnets.reduce({}) | $subnets, $subnet | {
      $output = $subnets + {
        $subnet[0] => deep_merge($subnet_defaults, $subnet[1])
      }
    }
    create_resources('iscdhcp::server::v4::subnet', $merged_subnets)
  }
  $networks.keys.each | $shared_network | {
    concat::fragment { "dhcpd.conf_${shared_network}":
      target  => "${dhcp_dir}/dhcpd.conf",
      content => "include \"${dhcp_dir}/networks/v4/${shared_network}.conf\";\n",
      order   => 4,
    }
  }
}
