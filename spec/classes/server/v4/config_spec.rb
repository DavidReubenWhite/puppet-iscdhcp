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
            'parameters' => {
              'authoritative'      => false,
              'ping_check'         => false,
              'min_lease_time'     => 600,
              'max_lease_time'     => 600,
              'default_lease_time' => 600,
            },
            'permissions' => {
              'client_updates' => 'allow',
            },
            'options' => {
              'routers'     => ['172.16.0.1'],
              'domain_name' => 'example.com',
            },
          },
          'iscdhcp::server::v4::subnet_defaults' => {
            'parameters' => {
              'max_lease_time' => 28_800,
              'authoritative' => true,
            },
            'options' => {
              'domain_name_servers' => ['8.8.8.8', '4.4.4.4'],
            },
          },
        )
      end

      it { is_expected.to compile.with_all_deps }
      it {
        is_expected.to contain_file('/etc/dhcp')
          .with('ensure' => 'directory')
      }
      it {
        is_expected.to contain_file('/etc/dhcp/networks')
          .with('ensure' => 'directory')
      }
      it {
        is_expected.to contain_file('/etc/dhcp/networks/v4')
          .with('ensure' => 'directory')
      }
      it {
        is_expected.to contain_file('/etc/dhcp/enabled_services')
          .with('ensure' => 'directory')
      }
      it {
        is_expected.to contain_file('/etc/dhcp/enabled_services/v4')
          .with('ensure' => 'directory')
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
      # it {
      #   is_expected
      #     .to contain_concat__fragment('dhcpd.conf_shared_network_1')
      # }
      # it {
      #   is_expected
      #     .to contain_concat__fragment('dhcpd.conf_shared_network_2')
      # }
      it {
        is_expected
          .to contain_concat__fragment('dhcpd.conf__private')
      }
      # it {
      #   is_expected
      #     .to contain_concat('/etc/dhcp/networks/v4/shared_network_1.conf')
      # }
      # it {
      #   is_expected
      #     .to contain_concat__fragment('shared_network_1.conf_header')
      # }
      # it {
      #   is_expected
      #     .to contain_concat__fragment('shared_network_1.conf_footer')
      # }
      # it {
      #   is_expected
      #     .to contain_concat__fragment('shared_network_2.conf_header')
      # }
      # it {
      #   is_expected
      #     .to contain_concat__fragment('shared_network_2.conf_footer')
      # }
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
          .to contain_concat__fragment('172.16.0.0/24_template')
      }
      it {
        is_expected
          .to contain_concat__fragment('172.16.0.0/24_footer')
      }
      it {
        is_expected
          .to contain_concat__fragment('172.16.0.0/24_pool_0')
      }
      it {
        is_expected
          .to contain_concat__fragment('172.16.0.0/24_pool_1')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.0.0/24_template')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.0.0/24_footer')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.1.0/24_template')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.1.0/24_footer')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.1.0/24_pool_0')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.2.7/32_template')
      }
      it {
        is_expected
          .to contain_concat__fragment('192.168.2.7/32_footer')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__pool('172.16.0.0/24_pool_0')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__pool('172.16.0.0/24_pool_1')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v4__pool('192.168.1.0/24_pool_0')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__host('172.16.0.50')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__host('grego')
      }
      it {
        is_expected
          .to contain_class('Iscdhcp::Server::V4::Global_defaults')
      }
      it {
        is_expected
          .to contain_concat__fragment('host_172.16.0.50')
      }
      it {
        is_expected
          .to contain_concat__fragment('host_grego')
      }
      it {
        is_expected
          .to contain_exec('test dhcpd config')
      }
      it {
        is_expected
          .to contain_service('dhcpd')
      }
      context 'with multiple failover peers in subnets hash' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::subnets' => {
              '172.28.0.0/24' => {
                'declarations' => {
                  'pools' => [
                    {
                      'parameters' => {
                        'failover_peer' => 'failover1.com',
                      },
                      'declarations' => {
                        'range' => {
                          'start'   => '172.16.0.10',
                          'end'     => '172.16.0.50',
                        },
                      },
                    },
                  ],
                },
              },
              '172.29.0.0/24' => {
                'declarations' => {
                  'pools' => [
                    {
                      'parameters' => {
                        'failover_peer' => 'failover2.com',
                      },
                      'declarations' => {
                        'range' => {
                          'start'   => '172.16.0.10',
                          'end'     => '172.16.0.50',
                        },
                      },
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
