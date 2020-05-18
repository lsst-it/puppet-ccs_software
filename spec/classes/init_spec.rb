# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) do
    {
      hostname: 'foo',
    }
  end

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

  describe 'with envs + location parameter' do
    let(:params) do
      {
        envs: {
          master: {},
          '1.0.0': {},
          'ETCCB-269': {},
        },
        location: 'ComCam',
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
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}")
          .that_notifies("Exec[install.py of #{c} env]")
      end
    end
  end

  describe 'with envs + location key' do
    let(:params) do
      {
        envs: {
          master: {
            location: 'ComCam',
          },
          '1.0.0': {
            location: 'ComCam',
          },
          'ETCCB-269': {
            location: 'ComCam',
          },
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
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}")
          .that_notifies("Exec[install.py of #{c} env]")
      end

      it do
        is_expected.to contain_exec("install.py of #{c} env").with(
          command: "/opt/lsst/ccsadm/release/bin/install.py --ccs_inst_dir /opt/lsst/ccs/#{c} /opt/lsst/ccsadm/package-lists/#{c}/ComCam/foo/ccsApplications.txt",
          creates: "/opt/lsst/ccs/#{c}",
          user: 'ccs',
          group: 'ccs',
          tries: 3,
        )
      end
    end
  end

  describe 'without location param or env key' do
    let(:params) do
      {
        envs: {
          master: {},
        },
      }
    end

    it { is_expected.to compile.and_raise_error(%r{env has does not have a location}) }
  end

  describe 'without hostname param or env key' do
    # the hostname param default comes from the $facts['hostname']
    let(:facts) do
      {
        hostname: nil,
      }
    end

    let(:params) do
      {
        envs: {
          master: {},
        },
        location: 'ComCam',
      }
    end

    it { is_expected.to compile.and_raise_error(%r{env has does not have a hostname}) }
  end

  describe 'with envs with conflicting refs/paths' do
    let(:params) do
      {
        envs: {
          master: {},
          test: {
            ref: 'master',
            path: '/opt/lsst/ccsadmin/package-lists/master',
          },
        },
        location: 'ComCam',
      }
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/package-lists/master').with(
        ensure: 'latest',
        provider: 'git',
        source: 'https://github.com/lsst-camera-dh/dev-package-lists',
        revision: 'master',
        user: 'ccs',
      )
    end

    it { is_expected.not_to contain_vcsrepo('/opt/lsst/ccsadm/package-lists/test') }
  end
end
