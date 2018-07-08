require 'spec_helper_local'

describe 'iscdhcp::server::v4::service' do
  include_context 'base_params'
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp_dir',
          'iscdhcp::server::v4::service_name' => 'dhcpd',
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_exec('test dhcpd config') }
      it { is_expected.to contain_service('dhcpd') }
    end
  end
end
