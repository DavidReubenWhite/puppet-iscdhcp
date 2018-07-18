function failover_names(Hash $subnets) >> Array {
  # we need to get all the pools out of the subnets so we can check
  # for failover peers.
  $all_pools = $subnets.reduce([]) | $pools, $subnets | {
    if has_key($subnets[1], 'declarations') {
      if has_key($subnets[1]['declarations'], 'pools') {
        $output = $pools + $subnets[1]['declarations']['pools']
      }
      else {
        $output = $pools
      }
    }
    else {
      $output = $pools
    }
  }
  #failover peers
  $fp = $all_pools.reduce([]) | $peers, $pools | {
    if has_key($pools, 'parameters') {
      if has_key($pools['parameters'], 'failover_peer') {
      $output = $peers + $pools['parameters']['failover_peer']
      }
      else {
        $output = $peers
      }
    }
    else {
      $output = $peers
    }
  }
  $subnet_failover_peers = unique($fp)
}
$subnets = {
  '192.168.2.0/24' => {
    declarations => {
      pools          => [
        {
          options      => {
            domain_name_servers => ['192.168.2.250', '192.168.2.251']
          },
          parameters   => {
            max_lease_time => '900',
            failover_peer  => 'blah.com',
          },
          declarations => {
            range => {
              start => '192.168.2.10',
              end   => '192.168.2.20'
            },
          },
        },
        {
          options      => {
            domain_name_servers => ['192.168.2.250', '192.168.2.251']
          },
          parameters   => {
            max_lease_time => '900',
          },
          declarations => {
            range => {
              start => '192.168.2.30',
              end   => '192.168.2.40'
            },
          },
        },
      ],
    },
  },
  '192.168.1.0/24' => {
    declarations => {
      shared_network => 'shared_network_1',
      pools          => [
        {
          options      => {
            domain_name_servers => ['192.168.1.250', '192.168.1.251']
          },
          parameters   => {
            max_lease_time => '900',
            failover_peer  => 'blah.com',
          },
          declarations => {
            range => {
              start => '192.168.1.10',
              end   => '192.168.1.20'
            },
          },
        },
        {
          options      => {
            domain_name_servers => ['192.168.1.250', '192.168.1.251']
          },
          parameters   => {
            max_lease_time => '900',
          },
          declarations => {
            range => {
              start => '192.168.1.30',
              end   => '192.168.1.40'
            },
          },
        },
      ],
      hosts          => {
        '172.16.0.50' => {
          permissions => {
            'client-updates' => 'allow',
          },
          parameters  => {
            host_identifier => {
              option => 'agent.remote-id',
              value  => 'REMOTEID12345679',
            },
            fixed_address   => ['172.16.0.50'],
          },
        },
        'grego'       => {
          parameters => {
            host_identifier => {
              option => 'agent.remote-id',
              value  => 'REMOTEID234567890',
            },
            hardware        => {
              hardware_type => 'ethernet',
              value         => '44:44:44:44:44:44',
            },
            fixed_address   => ['172.15.0.51'],
            ddns_updates    => 'off',
          },
        },
      },
    },
  },
}
$blah = failover_names($subnets)

      $content = inline_template("
      <%- require 'json' -%>
      <%= JSON.pretty_generate(@blah) %>
      ")
      notify{ $content :
        loglevel => notice,
      }






