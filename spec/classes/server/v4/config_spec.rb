require 'spec_helper_local'

describe 'iscdhcp::server::v4::config' do
  include_context 'base_params'
  let(:pre_condition) { 'class {"iscdhcp::server::v4::service": }' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        super().merge(
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v4::service_name' => 'dhcpd',
          'iscdhcp::server::v4::enabled_services' => [],
          'iscdhcp::server::v4::root_group' => 'root',
          'iscdhcp::server::v4::global_defaults' => {
            'authoritative' => false,
            'parameters' => {
              'ping-check'         => false,
              'min-lease-time'     => '600',
              'max-lease-time'     => '600',
              'default-lease-time' => '600',
            },
            'actions' => {
              'ignore' => ['client-updates'],
              'allow'  => [],
              'deny'   => [],
            },
            'options' => {
              'routers'     => '172.16.0.1',
              'domain-name' => 'example.com',
            },
          },
          'iscdhcp::server::v4::subnet_defaults' => {
            'authoritative' => true,
            'parameters' => {
              'max-lease-time' => '28800',
            },
            'options' => {
              'domain-name-servers' => ['8.8.8.8', '4.4.4.4'],
            },
          },
        )
      end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file('/etc/dhcp/networks')
          .with('ensure' => 'directory', 'purge' => true)
      }
      it {
        is_expected.to contain_file('/etc/dhcp/networks/v4')
          .with('ensure' => 'directory', 'purge' => true)
      }
      it {
        is_expected.to contain_file('/etc/dhcp/enabled_services')
          .with('ensure' => 'directory', 'purge' => true)
      }
      it { is_expected.to contain_concat('/etc/dhcp/dhcpd.conf') }

      it {
        is_expected
          .to contain_concat__fragment('/etc/dhcp/dhcpd.conf_header')
      }
      it {
        is_expected
          .to contain_concat__fragment('/etc/dhcp/dhcpd.conf_global_defaults')
      }
      it {
        is_expected
          .to contain_concat__fragment('dhcpd.conf_shared_network_1')
      }
      it {
        is_expected
          .to contain_concat__fragment('dhcpd.conf__private')
      }
      it {
        is_expected
          .to contain_concat('/etc/dhcp/networks/v4/shared_network_1.conf')
      }
      it {
        is_expected
          .to contain_concat__fragment('shared_network_1.conf_header')
      }
      it {
        is_expected
          .to contain_concat__fragment('shared_network_1.conf_footer')
      }
      it {
        is_expected
          .to contain_concat('/etc/dhcp/networks/v4/_private.conf')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__subnet('172.16.0.0/24')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__subnet('192.168.0.0/24')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__subnet('192.168.1.0/24')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__subnet('192.168.2.7/32')
      }
      it {
        is_expected
          .to contain_concat__fragment('172.16.0.0/24_subnet')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.0.0/24_subnet')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.1.0/24_subnet')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.2.7/32_subnet')
      }
      context 'with multiple failover peers in subnets hash' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::subnets' => {
              '172.28.0.0/24' => {
                'parameters' => {
                  'pools' => [
                    {
                      'failover_peer' => 'failover1.com',
                      'range_start'   => '172.16.0.10',
                      'range_end'     => '172.16.0.50',
                    },
                  ],
                },
              },
              '172.29.0.0/24' => {
                'parameters' => {
                  'pools' => [
                    {
                      'failover_peer' => 'failover2.com',
                      'range_start'   => '172.16.0.10',
                      'range_end'     => '172.16.0.50',
                    },
                  ],
                },
              },
            },
          )
        end

        it {
          is_expected.to compile
            .and_raise_error(%r{.*can only have one unique failover peer.*})
        }
      end
    end
  end
end
