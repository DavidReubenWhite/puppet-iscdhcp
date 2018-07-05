require 'spec_helper_local'

describe 'iscdhcp::server::v4::subnet' do
  include_context "base_params"
  let(:title) { '10.0.0.0/24' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'hosts' => {
            'hostblah' => {
              'parameters' => {
                'host-identifier' => {
                'option' => 'agent.remote-id',
                'value'  => 'REMOTEID12345679',
                }
              }
            }
          }
        }
      end
      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('10.0.0.0/24_subnet') }
      context "with host-identifier option missing" do
        let(:params) do
          super().merge(
            'hosts' => {
              'hostblah' => {
                'parameters' => {
                  'host-identifier' => {
                  'value' => 'REMOTEID12345679'
                  }
                }
              }
            }
          )
        end
        it { is_expected.to compile.and_raise_error(%r{if host-identifier specified, must contain an option and value})}
      end
      context "with host-identifier value missing" do
        let(:params) do
          super().merge(
            'hosts' => {
              'hostblah' => {
                'parameters' => {
                  'host-identifier' => {
                  'option' => 'agent.remote-id',
                  }
                }
              }
            }
          )
        end
        it { is_expected.to compile.and_raise_error(%r{if host-identifier specified, must contain an option and value})}
      end
    end
  end
end
