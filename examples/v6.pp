class { 'iscdhcp::server::v6':
  enabled_services => [],
  global_defaults  => {
    authoritative => true,
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
  },
  subnet_defaults  => {
    authoritative => true,
    parameters    => {
      'max-lease-time'     => '900',
      'min-lease-time'     => '900',
      'default-lease-time' => '900',
    },
    options       => {
      'dhcp6.name-servers' => ['2406:5a00:0:1::', '2406:5a00:0:1::1'],
      'domain-name'        => 'barry.com',
    },
  },
  subnets          => {
    '2406:5a00:0:11::/64' => {
      authoritative  => true,
      shared_network => 'shared_network_2',
      parameters     => {
        pools => [
          {
          range_start => '2406:5a00:2:93::10',
          range_end   => '2406:5a00:2:93::ffff:ffff',
          },
        ],
        pd    => {
          start => '2406:5a00:f400::',
          end   => '2406:5a00:f4ff:ff00::',
          mask  => 56,
        },
      },
      options        => {
        'domain-name' => 'larry.com',
      }
    },
  },
}
