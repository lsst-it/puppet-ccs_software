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
        user: 'ccs',
        require: 'File[/opt/lsst/ccsadm]',
      )
    end
  end

  describe 'with installations + env parameter' do
    let(:params) do
      {
        installations: {
          master: {},
          '1.0.0': {},
          'ETCCB-269': {},
        },
        env: 'ComCam',
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
          require: 'File[/opt/lsst/ccsadm/package-lists]',
        )
      end
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}")
          .that_notifies("Exec[install.py #{c}]")
      end
    end
  end

  describe 'with installations + env key' do
    let(:params) do
      {
        installations: {
          master: {
            env: 'ComCam',
          },
          '1.0.0': {
            env: 'ComCam',
          },
          'ETCCB-269': {
            env: 'ComCam',
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
          require: 'File[/opt/lsst/ccsadm/package-lists]',
        )
      end
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}")
          .that_notifies("Exec[install.py #{c}]")
      end

      it do
        is_expected.to contain_exec("install.py #{c}").with(
          command: "/opt/lsst/ccsadm/release/bin/install.py --ccs_inst_dir /opt/lsst/ccs/#{c} /opt/lsst/ccsadm/package-lists/#{c}/ComCam/foo/ccsApplications.txt",
          creates: "/opt/lsst/ccs/#{c}",
          user: 'ccs',
          group: 'ccs',
          tries: 3,
          logoutput: true,
        )
      end
    end
  end

  describe 'without env param or installation key' do
    let(:params) do
      {
        installations: {
          master: {},
        },
      }
    end

    it { is_expected.to compile.and_raise_error(%r{installation has does not have a env}) }
  end

  describe 'without hostname param or installation key' do
    # the hostname param default comes from the $facts['hostname']
    let(:facts) do
      {
        hostname: nil,
      }
    end

    let(:params) do
      {
        installations: {
          master: {},
        },
        env: 'ComCam',
      }
    end

    it { is_expected.to compile.and_raise_error(%r{installation has does not have a hostname}) }
  end

  describe 'with installations with conflicting refs/paths' do
    let(:params) do
      {
        installations: {
          master: {},
          test: {
            repo_ref: 'master',
            repo_path: '/opt/lsst/ccsadmin/package-lists/master',
          },
        },
        env: 'ComCam',
      }
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/package-lists/master').with(
        ensure: 'latest',
        provider: 'git',
        source: 'https://github.com/lsst-camera-dh/dev-package-lists',
        revision: 'master',
        user: 'ccs',
        require: 'File[/opt/lsst/ccsadm/package-lists]',
      )
    end

    it { is_expected.not_to contain_vcsrepo('/opt/lsst/ccsadm/package-lists/test') }
  end

  describe 'installation with aliases' do
    let(:params) do
      {
        installations: {
          test: {
            aliases: ['foo', 'bar', 'baz'],
          },
        },
        env: 'ComCam',
      }
    end

    ['foo', 'bar', 'baz'].each do |a|
      it do
        is_expected.to contain_file("/opt/lsst/ccs/#{a}").with(
          ensure: 'link',
          target: '/opt/lsst/ccs/test',
        )
      end
    end
  end
end
