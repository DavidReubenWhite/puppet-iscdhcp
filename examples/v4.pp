$input = @(FREEFORM)
# set lt (a printable version of the lease time) to either the actual lease time, or undefined
set lt = pick(binary-to-ascii(10, 32, "", option dhcp-lease-time), "undefined");
if (exists agent.circuit-id and exists agent.remote-id) {
  log(info,
    concat("Option 82: ",
      "received a REQUEST DHCP packet from relay-agent ",
      binary-to-ascii(10, 8, ".", packet(24, 4)),
      " with a circuit-id of \"",
      binary-to-ascii(16, 8, ":", option agent.circuit-id),
      "\" and remote-id of \"",
      binary-to-ascii(16, 8, ":", option agent.remote-id),
      "\" for ",
      binary-to-ascii(10, 8, ".", leased-address),
      " \(", binary-to-ascii(16, 8, ":", packet(28,6)), "\)",
      " lease time is ", lt, " seconds."
      )
    );
}
else if exists agent.circuit-id {
  log(info,
    concat("Option 82: ",
      "received a REQUEST DHCP packet from relay-agent ",
      binary-to-ascii(10, 8, ".", packet(24, 4)),
      " with a circuit-id of \"",
      binary-to-ascii(16, 8, ":", option agent.circuit-id),
      "\" for ",
      binary-to-ascii(10, 8, ".", leased-address),
      " \(", binary-to-ascii(16, 8, ":", packet(28,6)), "\)",
      " lease time is ", lt, " seconds."
      )
    );
}
else if exists agent.remote-id {
  log(info,
    concat("Option 82: ",
      "received a REQUEST DHCP packet from relay-agent ",
      binary-to-ascii(10, 8, ".", packet(24, 4)),
      " with a remote-id of \"",
      binary-to-ascii(16, 8, ":", option agent.remote-id),
      "\" for ",
      binary-to-ascii(10, 8, ".", leased-address),
      " \(", binary-to-ascii(16, 8, ":", packet(28,6)), "\)",
      " lease time is ", lt, " seconds."
      )
    );
}
FREEFORM

class { 'iscdhcp::server::v4':
  enabled_services             => ['dns_updater',
                        'omapi_listener',
                        'pxe_server',
                        'freeform_input',
                        'failover',],
  freeform_input               => $input,
  global_defaults              => {
    authoritative => false,
    parameters    => {
      'ping-check'         => false,
      'min-lease-time'     => '600',
      'max-lease-time'     => '600',
      'default-lease-time' => '600',
    },
    actions       => {
      ignore => ['client-updates',],
      allow  => [],
      deny   => [],
    },
    options       => {
      'routers'     => '172.16.0.1',
      'domain-name' => 'example.com',
    }
  },
  subnet_defaults              => {
    authoritative => true,
    parameters    => {
      'max-lease-time' => '28800',
    },
    options       => {
      'domain-name-servers' => ['8.8.8.8', '4.4.4.4',],
    },
  },
  subnets                      => {
    '192.168.0.0/24' => {
      authoritative    => false,
      'shared_network' => 'shared_network_1',
      parameters       => {
        'min-lease-time' => '900',
      },
      options          => {
        'routers'        => '192.168.0.1',
      },
    },
    '192.168.1.0/24' => {
      'shared_network' => 'shared_network_1',
      parameters       => {
        'min-lease-time' => '900',
        'pools'          => [
          {
            failover_peer => 'blah.com',
            range_start   => '192.168.1.20',
            range_end     => '192.168.1.30',
          }
        ]
      },
      hosts            => {
        '192.168.1.10' => {
          parameters => {
            'host-identifier' => {
              option => 'agent.remote-id',
              value  => 'REMOTEID12345679',
            },
            'fixed-address'   => '192.168.1.10',
          },
        },
      },
      options          => {
        'routers'        => '192.168.1.1',
      },

    },
    '172.16.0.0/24'  => {
      parameters => {
        'min-lease-time' => '900',
        'max-lease-time' => '86400',
        'pools'          => [
          {
            failover_peer => 'blah.com',
            range_start   => '172.16.0.10',
            range_end     => '172.16.0.50',
          },
          {
            failover_peer => 'blah.com',
            range_start   => '172.16.0.100',
            range_end     => '172.16.0.150'
          }
        ],
      },
      options    => {
        routers               => '172.16.0.1',
        'domain-name-servers' => ['172.16.0.250', '172.16.0.251',],
      },
      hosts      => {
        '172.16.0.50' => {
          parameters => {
            'host-identifier' => {
              option => 'agent.remote-id',
              value  => 'REMOTEID12345679',
            },
            'fixed-address'   => '172.16.0.50',
          },
        },
        'grego'       => {
          parameters => {
            'host-identifier'   => {
              'option' => 'agent.remote-id',
              'value'  => 'REMOTEID234567890',
            },
            'hardware ethernet' => '44:44:44:44:44:44',
            'fixed-address'     => '172.15.0.51',
          },
          options    => {
            'ddns-updates' => 'off',
          }
        }
      },
    },
    '192.168.2.7/32' => {
      # host subnet for dhcp proxy / relay
      authoritative => false,
      'options'     => {
        'domain-name-servers' => false,
      },
    }
  },


  omapi_port                   => 7911,
  omapi_key_name               => 'bigkey',
  omapi_algorithm              => 'HMAC-MD5',
  omapi_secret                 => 'biglongsecret',


  dns_default_algorithm        => 'hmac-md5',
  dns_zone_keys                => {
    'dhcpupdate'             => {
      key_algorithm => 'hmac-md-blah',
      secret        => 'biglongsecret'
    },
    '0.168.192.in-addr.arpa' => {
      secret        => 'supersecret',
    }
  },
  dns_zones                    => {
    home                     => {
      primary => '127.0.0.1',
      key     => 'dhcpupdate',
    },
    '0.168.192.in-addr.arpa' => {
      primary => '172.16.5.150',
      key     => '0.168.192.in-addr.arpa',
    },
  },


  pxe_next_server              => '127.0.0.1',
  pxe_match_criteria           => 'arch',
  pxe_default_bootfile         => 'pxelinux.0',
  pxe_arch_to_bootfile_map     => [
                            ['00:06', 'grub2/i386-efi/core.efi'],
                            ['00:07', 'grub2/x86_64-efi/core.efi'],
                            ['00:09', 'grub2/x86_64-efi/core.efi']
                          ],
  pxe_vci_to_bootfile_map      => [
                            ['PXEClient:Arch:0000', 'i386-efi/core.efi'],
                            ['PXEClient:Arch:0007', 'x86_64-efi/core.efi']
                          ],

  failover_name                => 'blah.com',
  failover_role                => 'primary',
  failover_listen_port         => 530,
  failover_peer_port           => 529,
  failover_listen_address      => 'server1.bighostname.com',
  failover_peer_address        => 'server2.bighostname.com',
  failover_max_response_delay  => 60,
  failover_max_unacked_updates => 10,
  failover_mclt                => 3600,
  failover_split               => 128,
  failover_load_balance_max_s  => 3,
}
