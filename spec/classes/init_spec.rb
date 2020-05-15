require 'spec_helper'

describe 'ccs_software' do
  describe "without any parameters" do
    it { should compile.with_all_deps }

    [
      '/opt/lsst',
      '/opt/lsst/ccs',
      '/opt/lsst/ccsadm',
      '/opt/lsst/ccsadm/dev-package-lists',
    ].each do |dir|
      it { is_expected.to contain_file(dir).with(ensure: 'directory') }
    end
  end
end
