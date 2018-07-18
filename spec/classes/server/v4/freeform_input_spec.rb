require 'spec_helper_local'

describe 'iscdhcp::server::v4::freeform_input' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        { 'iscdhcp::server::v4::freeform_input' => '',
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp' }
      end

      it { is_expected.to compile }
      it {
        is_expected
          .to contain_file('/etc/dhcp/enabled_services/v4/freeform_input.conf')
      }
    end
  end
end
