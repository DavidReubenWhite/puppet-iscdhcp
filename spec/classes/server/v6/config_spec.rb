require 'spec_helper'

describe 'iscdhcp::server::v6::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          'iscdhcp::server::v6::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v6::enabled_services' => [],
          'iscdhcp::server::v6::global_defaults' => {
            'parameters' => {
              'authoritative' => false,
              'ping_check' => false,
              'min_lease-time' => 600,
              'max_lease-time' => 600,
              'default_lease_time' => 600,
            },
            'permissions' => {
              'client_updates' => 'ignore',
            },
            'options' => {
              'routers' => ['fe80::1'],
              'domain_name' => 'example.com',
            },
          },
          'iscdhcp::server::v6::subnet_defaults' => {
            'parameters' => {
              'max_lease_time' => 28_800,
              'authoritative' => true,
            },
          },
          'iscdhcp::server::v6::subnets' => {
            '2406:5a00:0:11::/64' => {
              'declarations' => {
                'authoritative'  => true,
                'shared_network' => 'shared_network_2',
              },
              'parameters' => {
                'pools' => [
                  {
                    'declarations' => {
                      'range' => {
                        'start' => '2406:5a00:2:93::10',
                        'end'   => '2406:5a00:2:93::ffff:ffff',
                      },
                    },
                  },
                ],
                'pd' => {
                  'start' => '2406:5a00:f400::',
                  'end'   => '2406:5a00:f4ff:ff00::',
                  'mask'  => 56,
                },
              },
              'options' => {
                'domain-name' => 'larry.com',
              },
            },
          },
        }
      end

      it { is_expected.to compile }
      it {
        is_expected
          .to contain_file('/etc/dhcp').with('ensure' => 'directory')
      }
      it {
        is_expected
          .to contain_file('/etc/dhcp/networks').with('ensure' => 'directory')
      }
      it {
        is_expected
          .to contain_file('/etc/dhcp/networks/v6')
          .with('ensure' => 'directory')
      }
      it {
        is_expected
          .to contain_file('/etc/dhcp/enabled_services').with('ensure' => 'directory')
      }
      it {
        is_expected
          .to contain_file('/etc/dhcp/enabled_services/v6').with('ensure' => 'directory')
      }
      it {
        is_expected
          .to contain_concat('/etc/dhcp/dhcpd6.conf')
      }
      it {
        is_expected
          .to contain_concat('/etc/dhcp/networks/v6/shared_network_2.conf')
      }
      it {
        is_expected
          .to contain_concat__fragment('/etc/dhcp/dhcpd6.conf_header')
      }
      it {
        is_expected
          .to contain_concat__fragment('/etc/dhcp/dhcpd6.conf_global_defaults')
      }
      it {
        is_expected
          .to contain_concat__fragment('dhcpd6.conf_shared_network_2')
      }
      it {
        is_expected
          .to contain_concat__fragment('shared_network_2.conf_footer')
      }
      it {
        is_expected
          .to contain_concat__fragment('shared_network_2.conf_header')
      }
      it {
        is_expected
          .to contain_iscdhcp__server__v6__subnet('2406:5a00:0:11::/64')
      }
    end
  end
end
