require 'spec_helper_local'

describe 'iscdhcp::server::v4::dns_updater' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do {
        'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
        'iscdhcp::server::v4::root_group' => 'root',

        'iscdhcp::server::v4::dns_update_style' => 'interim',
        'iscdhcp::server::v4::dns_client_updates' => 'deny',
        'iscdhcp::server::v4::dns_default_algorithm' => 'hmac-md5',
        'iscdhcp::server::v4::dns_zone_keys'         => {
          'dhcpupdate'             => {
            'key_algorithm' => 'hmac-md5',
            'secret'        => 'biglongsecret'
          },
          '0.168.192.in-addr.arpa' => {
            'secret'        => 'supersecret',
          }
        },
        'iscdhcp::server::v4::dns_zones'             => {
          'home'                     => {
            'primary' => '127.0.0.1',
            'key'     => 'dhcpupdate',
          },
          '0.168.192.in-addr.arpa' => {
            'primary' => '172.16.5.150',
            'key'     => '0.168.192.in-addr.arpa',
          },
        },
      }
      end
      it { is_expected.to compile }
      it { is_expected
        .to contain_file('/etc/dhcp/enabled_services/dns_updater.conf')
      }
      context "with missing dns_zone 'primary' key" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::dns_zones' => {
              'home' => {
                'key' => 'dhcpupdate',
              },
            },
          )
        end
        it { is_expected.to compile
          .and_raise_error(%r{.*missing a key.*})}
      end
      context "with missing dns_zone 'key' key" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::dns_zones' => {
              'home' => {
                'primary' => '172.16.5.150',
              },
            },
          )
        end
        it { is_expected.to compile
          .and_raise_error(%r{.*missing a key.*})}
      end
      context "with a non existent zone key" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::dns_zone_keys' => {
              'dhcpupdate' => {
                'key_algorithm' => 'hmac-md6',
                'secret' => 'biglongsecret'
              },
            },
            'iscdhcp::server::v4::dns_zones' => {
              'home' => {
                'primary' => '127.0.0.1',
                'key' => 'blahblahblah',
              },
            },
          )
        end
        it { is_expected.to compile
          .and_raise_error(%r{.*does not have a corresponding key.*})}
      end
      context "with no default algorithm set and missing local algorithm" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::dns_default_algorithm' => :undef,
          )
        end
        it { is_expected.to compile.and_raise_error(%r{.*key_algorithm must be set per zone key.*}) }
      end
      # it { is_expected
      #        .to contain_file('/etc/dhcp/enabled_services/dns_updater.conf')
      #          .with_content(%r{.*algorithm undef;.*})
      # }
    end
  end
end
