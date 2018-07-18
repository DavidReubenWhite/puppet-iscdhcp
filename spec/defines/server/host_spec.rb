require 'spec_helper'

describe 'iscdhcp::server::host' do
  let(:title) { 'barry' }
  let(:params) do
    {
      'target' => '/etc/dhcp/networks/v4/shared_network_1.conf',
      'replace' => '  ',
      'order' => 3,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('host_barry') }
    end
  end
end
