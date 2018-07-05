require 'spec_helper_local'

describe 'iscdhcp::server::v4::omapi_listener' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v4::root_group' => 'root',
          'iscdhcp::server::v4::omapi_port' => 7911,
          'iscdhcp::server::v4::omapi_key_name' => 'bigkey',
          'iscdhcp::server::v4::omapi_algorithm' => 'HMAC-MD5',
          'iscdhcp::server::v4::omapi_secret' => 'biglongsecret',
        }
      end
      it { is_expected.to compile }
      it { is_expected
        .to contain_file('/etc/dhcp/enabled_services/omapi_listener.conf')
      }
      context "with omapi_key_name not set" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::omapi_key_name' => :undef,
          )
        end
        it { is_expected.to compile
          .and_raise_error(%r{.*`omapi_key_name` must be set.*})
        }
      end
      context "with omapi_secret not set" do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::omapi_secret' => :undef,
          )
        end
        it { is_expected.to compile
          .and_raise_error(%r{.*`omapi_secret` must be set.*})
        }
      end
    end
  end
end
