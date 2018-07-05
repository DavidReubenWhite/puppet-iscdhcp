require 'spec_helper_local'

describe 'iscdhcp::server::v4' do
  let(:params) do
    {

      'omapi_port' => 7911,
      'omapi_key_name' => 'bigkey',
      'omapi_algorithm' => 'HMAC-MD5',
      'omapi_secret' => 'biglongsecret',

      'failover_name' => 'blah.com',
      'failover_role' => 'primary',
      'failover_listen_port' => 530,
      'failover_peer_port' => 529,
      'failover_listen_address' => 'server1.bighostname.com',
      'failover_peer_address' => 'server2.bighostname.com',
      'failover_max_response_delay' => 60,
      'failover_max_unacked_updates' => 10,
      'failover_mclt' => 3600,
      'failover_split' => 128,
      'failover_load_balance_max_s' => 3,

      'dns_zone_keys'         => {
        'dhcpupdate'             => {
          'key_algorithm' => 'hmac-md6',
          'secret'        => 'biglongsecret'
        },
        '0.168.192.in-addr.arpa' => {
          'secret'        => 'supersecret',
        }
      },
      'dns_zones'             => {
        'home'                     => {
          'primary' => '127.0.0.1',
          'key'     => 'dhcpupdate',
        },
        '0.168.192.in-addr.arpa' => {
          'primary' => '172.16.5.150',
          'key'     => '0.168.192.in-addr.arpa',
        },
      },

      'pxe_next_server' => '127.0.0.1',
      'pxe_arch_to_bootfile_map' => [
                  ['00:06', 'grub2/i386-efi/core.efi'],
                  ['00:07', 'grub2/x86_64-efi/core.efi'],
                  ['00:09', 'grub2/x86_64-efi/core.efi']
                ],

      'global_defaults' => {
        'authoritative' => false,
        'parameters'    => {
          'ping-check'         => false,
          'min-lease-time'     => '600',
          'max-lease-time'     => '600',
          'default-lease-time' => '600',
        },
        'actions'       => {
          'ignore' => ['client-updates',],
          'allow'  => [],
          'deny'   => [],
        },
        'options'       => {
          'routers'     => '172.16.0.1',
          'domain-name' => 'example.com',
        }
      },
      'subnets' => {
        '192.168.0.0/24' => {
          'authoritative'    => false,
          'shared_network' => 'shared_network_1',
          'parameters'       => {
            'min-lease-time' => '900',
          },
          'options'          => {
            'routers'        => '192.168.0.1',
          },
        },
        '192.168.1.0/24' => {
          'shared_network' => 'shared_network_1',
          'parameters'       => {
            'min-lease-time' => '900',
            'pools'          => [
              {
                'failover_name' => 'blah.com',
                'range_start'   => '192.168.1.20',
                'range_end'     => '192.168.1.30',
              }
            ]
          },
          'options'          => {
            'routers'        => '192.168.1.1',
          },
        },
        '172.16.0.0/24'  => {
          'parameters' => {
            'min-lease-time' => '900',
            'max-lease-time' => '86400',
            'pools'          => [
              {
                'failover_name' => 'blah.com',
                'range_start'   => '172.16.0.10',
                'range_end'     => '172.16.0.50',
              },
              {
                'failover_name' => 'blah.com',
                'range_start'   => '172.16.0.100',
                'range_end'     => '172.16.0.150'
              }
            ],
          },
          'options'    => {
            'routers'               => '172.16.0.1',
            'domain-name-servers' => ['172.16.0.250', '172.16.0.251',],
          },
          'hosts'      => {
            '172.16.0.50' => {
              'parameters' => {
                'host-identifier' => {
                  'option' => 'agent.remote-id',
                  'value'  => 'REMOTEID12345679',
                },
                'fixed-address'   => '172.16.0.50',
              },
            },
            'grego'       => {
              'parameters' => {
                'host-identifier' => {
                  'option' => 'agent.remote-id',
                  'value'  => 'REMOTEID234567890',
                },
                'hardware'        => '44:44:44:44:44:44',
                'fixed-address'   => '172.15.0.51',
              },
              'options'    => {
                'ddns-updates' => 'off',
              }
            }
          }
        },
        '192.168.2.7/32' => {
          # host subnet for dhcp proxy / relay
          'authoritative'  => false,
        }
      },
    }
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      it { is_expected.to compile }
      it { is_expected.to contain_class('iscdhcp::server::v4::install') }
      it { is_expected.to contain_class('iscdhcp::server::v4::config').that_requires('Class[iscdhcp::server::v4::install]') }
      it { is_expected.to contain_class('iscdhcp::server::v4::config').that_notifies('Class[iscdhcp::server::v4::service]') }
      it { is_expected.to contain_class('iscdhcp::server::v4::service') }
      # nested context below
      context "with no subnets hash" do
        let(:params) do
          super().tap { | params | params.delete('subnets') }
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects.*subnets.*})}
      end
      context "with empty subnets hash" do
        let(:params) do
          super().merge(
            'subnets' => {},
          )
        end
        it { is_expected.to compile.and_raise_error(%r{parameter 'subnets' expects size to be at least 1.*})}
      end
      context "with incorrect subnets type" do
        let(:params) do
          super().merge(
            'subnets' => [],
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*subnets.*expects.*Hash.*})}
      end
      context "with invalid subnet CIDR" do
        let(:params) do
          super().merge(
            'subnets' => {
              '1922.168.1.0/24' => {}
            },
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*subnet.*not a valid V4 CIDR.*})}
      end
      context "with invalid subnet parameter" do
        let(:params) do
          super().merge(
            'subnets' => {
              '192.168.10.0/24' => {
                'garbage_parameter' => {}
              }
            },
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*unsupported subnet key used.*})}
      end
      context "unsupported os type (no dhcp_dir)" do
        let(:params) do
          # params take presidence over hiera. Can't actually remove the hiera value of dhcp_dir so we set it to empty.
          super().merge('dhcp_dir' => '')
        end
        it { is_expected.to compile.and_raise_error(%r{.*unsupported os.*})}
      end
      context "with incorrect enabled services" do
        let(:params) do
          super().merge(
            'enabled_services' => ['gravy']
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a match for Enum.*})}
      end
      context "with incorrect type for enabled services" do
        let(:params) do
          super().merge(
            'enabled_services' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*parameter 'enabled_services' expects a value of type Undef or Array.*})}
      end
      context "with incorrect type for freeform_input" do
        let(:params) do
          super().merge(
            'freeform_input' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*parameter 'freeform_input' expects a value of type Undef or String.*})}
      end
      context "with incorrect type for global_defaults" do
        let(:params) do
          super().merge(
            'global_defaults' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*parameter 'global_defaults' expects a value of type Undef or Hash.*})}
      end
      context "with incorrect type for subnet_defaults" do
        let(:params) do
          super().merge(
            'subnet_defaults' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Hash.*})}
      end
      context "with incorrect type for pxe_next_server" do
        let(:params) do
          super().merge(
            'pxe_next_server' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef, Stdlib::Fqdn.*Ipv4.*})}
      end
      context "with incorrect type for pxe_match_criteria" do
        let(:params) do
          super().merge(
            'pxe_match_criteria' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects an undef value or a match for Enum.*})}
      end
      context "with incorrect pxe_match_criteria value" do
        let (:params) do
          super().merge(
            'pxe_match_criteria' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects an undef value or a match for Enum.*})}
      end
      # this needs to be expanded to check if array contains tuple, string etc
      context "with incorrect type for pxe_arch_to_bootfile_map" do
        let (:params) do
          super().merge(
            'pxe_arch_to_bootfile_map' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Array.*})}
      end
      # this needs to be expanded to check if array contains tuple, string etc
      context "with incorrect type for pxe_vci_to_bootfile_map" do
        let (:params) do
          super().merge(
            'pxe_vci_to_bootfile_map' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Array.*})}
      end
      context "with incorrect type for pxe_default_bootfile" do
        let (:params) do
          super().merge(
            'pxe_default_bootfile' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for omapi_port" do
        let (:params) do
          super().merge(
            'omapi_port' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for omapi_algorithm" do
        let (:params) do
          super().merge(
            'omapi_algorithm' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for omapi_algorithm" do
        let (:params) do
          super().merge(
            'omapi_algorithm' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for omapi_key_name" do
        let (:params) do
          super().merge(
            'omapi_key_name' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for omapi_secret" do
        let (:params) do
          super().merge(
            'omapi_secret' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for dns_zone_keys" do
        let (:params) do
          super().merge(
            'dns_zone_keys' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Hash.*})}
      end
      context "with incorrect type for dns_zones" do
        let (:params) do
          super().merge(
            'dns_zones' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Hash.*})}
      end
      context "with incorrect type for dns_default_algorithm" do
        let (:params) do
          super().merge(
            'dns_default_algorithm' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for dns_update_style" do
        let (:params) do
          super().merge(
            'dns_update_style' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects an undef value or a match for Enum.*})}
      end
      context "with incorrect type for dns_client_updates" do
        let (:params) do
          super().merge(
            'dns_client_updates' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects an undef value or a match for Enum.*})}
      end
      context "with incorrect type for failover_name" do
        let (:params) do
          super().merge(
            'failover_name' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or String.*})}
      end
      context "with incorrect type for failover_listen_address" do
        let(:params) do
          super().merge(
            'failover_listen_address' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef, Stdlib::Fqdn.*Ipv4.*})}
      end
      context "with incorrect type for failover_peer_address" do
        let(:params) do
          super().merge(
            'failover_peer_address' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef, Stdlib::Fqdn.*Ipv4.*})}
      end
      context "with incorrect type for failover_role" do
        let (:params) do
          super().merge(
            'failover_role' => 1
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects an undef value or a match for Enum.*})}
      end
      context "with incorrect type for failover_listen_port" do
        let (:params) do
          super().merge(
            'failover_listen_port' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_peer_port" do
        let (:params) do
          super().merge(
            'failover_peer_port' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_max_response_delay" do
        let (:params) do
          super().merge(
            'failover_max_response_delay' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_max_unacked_updates" do
        let (:params) do
          super().merge(
            'failover_max_unacked_updates' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_mclt" do
        let (:params) do
          super().merge(
            'failover_mclt' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_split" do
        let (:params) do
          super().merge(
            'failover_split' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
      context "with incorrect type for failover_load_balance_max_s" do
        let (:params) do
          super().merge(
            'failover_load_balance_max_s' => 'gravy'
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*expects a value of type Undef or Integer.*})}
      end
    end
  end
end
