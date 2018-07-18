# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v6::config
class iscdhcp::server::v6::config {
  $dhcp_dir = lookup('iscdhcp::server::dhcp_dir')
  $root_group = lookup('iscdhcp::server::root_group')
  $service_name = lookup('iscdhcp::server::service_name')
  $global_defaults = $iscdhcp::server::v6::global_defaults
  $subnet_defaults = $iscdhcp::server::v6::subnet_defaults
  $subnets = $iscdhcp::server::v6::subnets
  $enabled_services = $iscdhcp::server::v6::enabled_services

  assert_private()

  $networks = iscdhcp::get_shared_networks($subnets)

  file {[
          $dhcp_dir,
          "${dhcp_dir}/networks",
          "${dhcp_dir}/networks/v6",
          "${dhcp_dir}/enabled_services",
          "${dhcp_dir}/enabled_services/v6",
        ]:
    ensure => 'directory',
    notify => Concat["${dhcp_dir}/dhcpd6.conf"],
  }
  concat { "${dhcp_dir}/dhcpd6.conf":
    ensure => present,
    #owner  => 'root',
    group  => $root_group,
    order  => 'numeric',
    mode   => '0640',
    #notify => Exec["test ${service_name} config"],
  }
  concat::fragment { "${dhcp_dir}/dhcpd6.conf_header":
    target  => "${dhcp_dir}/dhcpd6.conf",
    content => template('iscdhcp/server/v6/header.erb'),
    order   => 1,
  }
  $enabled_services.each | Integer $index, String $service | {
    class { "iscdhcp::server::v6::${service}": }
    # if it's the last enabled service to include - add an extra \n
    if ($index + 1) != length($enabled_services) {
      $content = {
        'content' => "include \"${dhcp_dir}/enabled_services/v6/${service}.conf\";\n"
      }
    }
    else {
      $content = {
        'content' => "include \"${dhcp_dir}/enabled_services/v6/${service}.conf\";\n\n"
      }
    }
    # put the index as the first dynamic part of fragment name to break tie for ordering
    concat::fragment { "${dhcp_dir}/dhcpd6.conf_${index}_${service}":
      target => "${dhcp_dir}/dhcpd6.conf",
      *      => $content,
      order  => 2,
    }
  }

  if $global_defaults {
    concat::fragment { "${dhcp_dir}/dhcpd6.conf_global_defaults":
      target  => "${dhcp_dir}/dhcpd6.conf",
      content => template('iscdhcp/server/v6/global_defaults.erb'),
      order   => 3,
    }
  }
  # each shared network goes in its own file (including no shared network)
  $networks.each | $shared_network, $subnets | {
    concat { "${dhcp_dir}/networks/v6/${shared_network}.conf":
      ensure => present,
      #owner  => 'root',
      group  => $root_group,
      order  => 'numeric',
      mode   => '0640',
      #notify => Exec["test ${service_name} config"],
    }
    # for each shared network we need the below extra statements to wrap around the subnets.
    if !($shared_network == '_private') {
      concat::fragment { "${shared_network}.conf_header":
        target  => "${dhcp_dir}/networks/v6/${shared_network}.conf",
        content => "shared-network \"${shared_network}\" {\n",
        order   => 1,
      }
      concat::fragment { "${shared_network}.conf_footer":
        target  => "${dhcp_dir}/networks/v6/${shared_network}.conf",
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
    create_resources('iscdhcp::server::v6::subnet', $merged_subnets)
  }
  $networks.keys.each | $shared_network | {
    concat::fragment { "dhcpd6.conf_${shared_network}":
      target  => "${dhcp_dir}/dhcpd6.conf",
      content => "include \"${dhcp_dir}/networks/v6/${shared_network}.conf\";\n",
      order   => 4,
    }
  }
}
