# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) do
    {
      networking: {
        hostname: 'foo',
      },
    }
  end
  let(:node_params) { { 'site' => 'ls' } }

  describe 'without any parameters' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_file('/lsst').with(
        ensure: 'symlink',
        owner: 'root',
        group: 'root',
        target: '/opt/lsst',
      )
    end

    it do
      is_expected.to contain_file('/opt/lsst').with(
        ensure: 'directory',
        owner: 'root',
        group: 'root',
      )
    end

    it do
      is_expected.to contain_file('/etc/ccs').with(
        ensure: 'directory',
        owner: 'ccsadm',
        group: 'ccsadm',
        mode: '2775',
      )
    end

    it do
      is_expected.to contain_file('/var/log/ccs').with(
        ensure: 'directory',
        owner: 'root',
        group: 'ccs',
        mode: '2777',
      )
    end

    %w[
      /opt/lsst/ccs
    ].each do |dir|
      it do
        is_expected.to contain_file(dir).with(
          ensure: 'directory',
          owner: 'ccsadm',
          group: 'ccs',
          mode: '1775',
        )
      end
    end

    %w[
      /opt/lsst/ccsadm
      /opt/lsst/ccsadm/package-lists
      /opt/lsst/ccsadm/scripts
    ].each do |dir|
      it do
        is_expected.to contain_file(dir).with(
          ensure: 'directory',
          owner: 'ccsadm',
          group: 'ccsadm',
          mode: '0755',
        )
      end
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/release').with(
        ensure: 'latest',
        provider: 'git',
        user: 'ccsadm',
        force: false,
        require: 'File[/opt/lsst/ccsadm]',
      )
    end

    it do
      is_expected.to contain_package('unzip')
      is_expected.to contain_package('git')
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

    %w[
      master
      1.0.0
      ETCCB-269
    ].each do |c|
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}").with(
          ensure: 'latest',
          provider: 'git',
          source: 'https://github.com/lsst-camera-dh/dev-package-lists',
          revision: c,
          user: 'ccsadm',
          force: false,
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

    %w[
      master
      1.0.0
      ETCCB-269
    ].each do |c|
      it do
        is_expected.to contain_vcsrepo("/opt/lsst/ccsadm/package-lists/#{c}").with(
          ensure: 'latest',
          provider: 'git',
          source: 'https://github.com/lsst-camera-dh/dev-package-lists',
          revision: c,
          user: 'ccsadm',
          force: false,
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
          user: 'ccsadm',
          group: 'ccsadm',
          tries: 3,
          logoutput: true,
        )
      end

      it do
        is_expected.to contain_exec("install.py #{c}")
          .that_notifies("Exec[chown #{c}]")
      end

      it do
        is_expected.to contain_exec("chown #{c}").with(
          path: '/bin:/usr/bin',
          provider: 'shell',
          logoutput: true,
          cwd: '/opt/lsst',
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
    # the hostname param default comes from the $facts['networking']['hostname']
    let(:facts) do
      {
        networking: {
          hostname: nil,
        },
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
        user: 'ccsadm',
        force: false,
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
            aliases: %w[foo bar baz],
          },
        },
        env: 'ComCam',
      }
    end

    %w[foo bar baz].each do |a|
      it do
        is_expected.to contain_file("/opt/lsst/ccs/#{a}").with(
          ensure: 'link',
          owner: 'ccsadm',
          group: 'ccsadm',
          target: '/opt/lsst/ccs/test',
        )
      end
    end
  end

  describe 'installation with git_force' do
    let(:params) do
      {
        env: 'ComCam',
        git_force: true,
        installations: {
          master: {},
        },
      }
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/release').with(
        ensure: 'latest',
        provider: 'git',
        user: 'ccsadm',
        force: true,
        require: 'File[/opt/lsst/ccsadm]',
      )
    end

    it do
      is_expected.to contain_vcsrepo('/opt/lsst/ccsadm/package-lists/master').with(
        ensure: 'latest',
        provider: 'git',
        source: 'https://github.com/lsst-camera-dh/dev-package-lists',
        revision: 'master',
        user: 'ccsadm',
        force: true,
        require: 'File[/opt/lsst/ccsadm/package-lists]',
      )
    end
  end
end
