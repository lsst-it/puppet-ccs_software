# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ccs_software class' do
  describe 'prepare host' do
    let(:pp) do
      <<-PP
      accounts::user { 'ccs': }
      accounts::user { 'ccsadm': }

      if versioncmp($facts['os']['release']['major'],'8') >= 0 {
        package { 'python3': }
        -> alternatives { 'python':
          path => '/usr/bin/python3',
        }
      }
      PP
    end

    it_behaves_like 'an idempotent resource'
  end

  context 'with trivial case without installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path => '#{basedir}',
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/lsst') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to basedir }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/etc/ccs') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'ccsadm' }
      it { is_expected.to be_grouped_into 'ccsadm' }
      it { is_expected.to be_mode '2775' }
    end

    %w[
      logging.properties
      ccsGlobal.properties
      udp_ccs.properties
    ].each do |f|
      describe file("/etc/ccs/#{f}") do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
        it { is_expected.to be_mode '664' } # serverspec does not like a leading 0
      end
    end

    describe file('/var/log/ccs') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'ccs' }
      it { is_expected.to be_mode '2777' }
    end

    [
      "#{basedir}/ccs",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccs' }
        it { is_expected.to be_mode '1775' }
      end
    end

    [
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/release",
      "#{basedir}/ccsadm/scripts",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
        it { is_expected.to be_mode '755' } # serverspec does not like a leading 0
      end
    end

    # package deps
    %w[unzip git].each do |p|
      describe package(p) do
        it { is_expected.to be_installed }
      end
    end

    # scripts
    %w[
      installCCS.sh
      showCCSProcesses.sh
      startStopCluster.sh
      updateCcsSudoerFile.sh
      updateInstallationSymlink.sh
      updateServiceFile.sh
      verifyUser.sh
    ].each do |s|
      describe file("#{basedir}/ccsadm/scripts/#{s}") do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
        it { is_expected.to be_mode '755' } # serverspec does not like a leading 0
      end
    end

    # log
    describe file('/etc/cron.daily/ccs-log-compress') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '755' } # serverspec does not like a leading 0
      its(:content) { is_expected.to match %r{archive_flag=n} }
    end

    describe file('/usr/local/bin/ccslog') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '755' }
    end

    describe file('/etc/bash_completion.d/ccslog.bash') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '644' }
    end
  end

  context 'with installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-mcm',
        env           => 'ComCam',
        installations => {
          'comcam-software-2.2.7' => {},
          'cb1f1e2' => {},  # commit at head ofd comcam-software-2.2.3 branch
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{basedir}/ccs/comcam-software-2.2.7",
      "#{basedir}/ccs/comcam-software-2.2.7/bin",
      "#{basedir}/ccs/cb1f1e2",
      "#{basedir}/ccs/cb1f1e2/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/comcam-software-2.2.7",
      "#{basedir}/ccsadm/package-lists/comcam-software-2.2.7/.git",
      "#{basedir}/ccsadm/package-lists/cb1f1e2",
      "#{basedir}/ccsadm/package-lists/cb1f1e2/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with complex installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        installations => {
          test1 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test1.foo",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
          test42 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test42.bar",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{basedir}/ccs/test1",
      "#{basedir}/ccs/test1/bin",
      "#{basedir}/ccs/test42",
      "#{basedir}/ccs/test42/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/test1.foo",
      "#{basedir}/ccsadm/package-lists/test1.foo/.git",
      "#{basedir}/ccsadm/package-lists/test42.bar",
      "#{basedir}/ccsadm/package-lists/test42.bar/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with shared git clones' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        installations => {
          test-mcm => {
            repo_path => "#{basedir}/ccsadm/package-lists/cb1f1e2",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
          test-fp => {
            repo_path => "#{basedir}/ccsadm/package-lists/cb1f1e2",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-fp01',
          },
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    [
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/cb1f1e2",
      "#{basedir}/ccsadm/package-lists/cb1f1e2/.git",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    [
      "#{basedir}/ccsadm/package-lists/test-mcm",
      "#{basedir}/ccsadm/package-lists/test-fp",
    ].each do |d|
      describe file(d) do
        it { is_expected.not_to exist }
      end
    end
  end

  context 'with aliases' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        env           => 'ComCam',
        hostname      => 'comcam-mcm',
        installations => {
          'comcam-software-2.2.7'  => {
            aliases => ['foo', 'bar', 'baz'],
          },
          'cb1f1e2' => {
            aliases => ['a', 'b', 'c'],
          },
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    [
      "#{basedir}/ccs/foo",
      "#{basedir}/ccs/bar",
      "#{basedir}/ccs/baz",
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{basedir}/ccs/comcam-software-2.2.7" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    [
      "#{basedir}/ccs/a",
      "#{basedir}/ccs/b",
      "#{basedir}/ccs/c",
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{basedir}/ccs/cb1f1e2" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with etc symlink' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-fp01',
        env           => 'ComCam',
        installations => {
          'comcam-software-1.0.6' => {},
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{basedir}/ccs/comcam-software-1.0.6",
      "#{basedir}/ccs/comcam-software-1.0.6/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/comcam-software-1.0.6",
      "#{basedir}/ccsadm/package-lists/comcam-software-1.0.6/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    # symlink created by install.py
    describe file("#{basedir}/ccs/comcam-software-1.0.6/etc") do
      it { is_expected.to be_symlink }
      # link is relative
      it { is_expected.to be_linked_to 'ccs-prod-configurations-comcam-software-1.0.6/ComCam/comcam-fp01' }
      it { is_expected.to be_owned_by 'ccsadm' }
      it { is_expected.to be_grouped_into 'ccsadm' }
    end

    [
      # symlink target dir
      "#{basedir}/ccs/comcam-software-1.0.6/ccs-prod-configurations-comcam-software-1.0.6/ComCam/comcam-fp01",
      # package containing symlink target dir
      "#{basedir}/ccs/comcam-software-1.0.6/ccs-prod-configurations-comcam-software-1.0.6",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccs' }
        it { is_expected.to be_grouped_into 'ccs' }
      end
    end

    # file in chown'd etc dir
    describe file("#{basedir}/ccs/comcam-software-1.0.6/etc/comcam-fp_safe_DAQ.properties") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'ccs' }
      it { is_expected.to be_grouped_into 'ccs' }
    end
  end

  context 'with services' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      # java is only needed to manually start services
      class { 'java_artisanal': }
      -> Class['ccs_software']

      class { 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-mcm',
        env           => 'ComCam',
        installations => {
          'cb1f1e2' => {
            aliases => ['dev'],
          },
        },
        services      => {
          dev => ['comcam-mcm', {name => 'h2db', cmd => '/bin/h2db'}],
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe service('comcam-mcm') do
      # does not work on el7
      # it { is_expected.to be_installed }
      it { is_expected.to be_enabled }
      it { is_expected.not_to be_running }
    end

    describe file('/etc/systemd/system/comcam-mcm.service') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{WorkingDirectory=/home/ccs} }
    end

    describe file('/etc/systemd/system/h2db.service') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match %r{ExecStart=/bin/h2db} }
    end
  end

  context 'with desktop' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path => '#{basedir}',
        desktop   => true,
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    %w[
      /etc/xdg/menus/applications-merged/lsst.menu
      /usr/share/desktop-directories/lsst.directory
      /usr/share/icons/lsst_appicon.png
      /usr/share/applications/lsst.ccs.console.prod.desktop
      /usr/share/applications/lsst.ccs.console.dev.desktop
      /usr/share/applications/lsst.ccs.shell.prod.desktop
      /usr/share/applications/lsst.ccs.shell.dev.desktop
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_grouped_into 'root' }
      end
    end
  end

  context 'with git_force' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-mcm',
        env           => 'ComCam',
        git_force     => true,
        installations => {
          'cb1f1e2' => {},
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    [
      "#{basedir}/ccsadm/package-lists/cb1f1e2",
      "#{basedir}/ccsadm/package-lists/cb1f1e2/.git",
      "#{basedir}/ccsadm/release",
      "#{basedir}/ccsadm/release/.git",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end
end
