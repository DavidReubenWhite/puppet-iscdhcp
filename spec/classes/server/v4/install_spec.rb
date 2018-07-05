require 'spec_helper_local'

describe 'iscdhcp::server::v4::install' do
  include_context "base_params"
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
