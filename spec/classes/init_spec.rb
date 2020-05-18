# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  describe 'without any parameters' do
    it { is_expected.to compile.with_all_deps }

    [
      '/opt/lsst',
      '/opt/lsst/ccs',
      '/opt/lsst/ccsadm',
      '/opt/lsst/ccsadm/package-lists',
    ].each do |dir|
      it { is_expected.to contain_file(dir).with(ensure: 'directory') }
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/release').with(
        ensure: 'latest',
        provider: 'git',
        source: 'https://github.com/lsst-camera-dh/release',
        revision: 'master',
        user: 'ccs',
      )
    end
  end

  describe 'with envs parameter' do
    let(:params) do
      {
        envs: {
          master: {},
          '1.0.0': {},
          'ETCCB-269': {},
        },
      }
    end

    [
      'master',
      '1.0.0',
      'ETCCB-269',
    ].each do |c|
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}").with(
          ensure: 'latest',
          provider: 'git',
          source: 'https://github.com/lsst-camera-dh/dev-package-lists',
          revision: c,
          user: 'ccs',
        )
      end
    end
  end
end
