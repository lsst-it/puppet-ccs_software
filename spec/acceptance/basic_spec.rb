# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ccs_software class' do
  let(:pp) do
    <<-EOS
    accounts::user { 'ccs': }
    -> class{ 'ccs_software': }
    EOS
  end

  it_behaves_like 'an idempotent resource'

  [
    '/opt/lsst',
    '/opt/lsst/ccs',
    '/opt/lsst/ccsadm',
    '/opt/lsst/ccsadm/package-lists',
  ].each do |dir|
    describe file(dir) do
      it { is_expected.to be_directory }
    end
  end
end
