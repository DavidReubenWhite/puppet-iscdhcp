require 'spec_helper_local'

describe 'iscdhcp::server::v4::pxe_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v4::root_group' => 'root',

          'iscdhcp::server::v4::pxe_next_server' => '127.0.0.1',
          'iscdhcp::server::v4::pxe_match_criteria' => 'arch',
          'iscdhcp::server::v4::pxe_default_bootfile' => 'pxelinux.0',
          'iscdhcp::server::v4::pxe_arch_to_bootfile_map' => [
            ['00:06', 'grub2/i386-efi/core.efi'],
            ['00:07', 'grub2/x86_64-efi/core.efi'],
            ['00:09', 'grub2/x86_64-efi/core.efi'],
          ],
          'iscdhcp::server::v4::pxe_vci_to_bootfile_map' => [
            ['PXEClient:Arch:0000', 'i386-efi/core.efi'],
            ['PXEClient:Arch:0007', 'x86_64-efi/core.efi'],
          ],
        }
      end

      it { is_expected.to compile }
      it {
        is_expected
          .to contain_file('/etc/dhcp/enabled_services/v4/pxe_server.conf')
      }
      context 'with missing pxe_next_server' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::pxe_next_server' => :undef,
          )
        end

        it {
          is_expected.to compile
            .and_raise_error(%r{.*if pxe_server is enabled, pxe_next_server must be set.*})
        }
      end
      context 'with missing pxe_arch_to_bootfile_map' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::pxe_arch_to_bootfile_map' => :undef,
          )
        end

        it {
          is_expected.to compile
            .and_raise_error(%r{.*if pxe_server is enabled, pxe_arch_to_bootfile_map must be set.*})
        }
      end
    end
  end
end
