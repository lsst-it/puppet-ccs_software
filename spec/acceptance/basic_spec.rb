# frozen_string_literal: true

require 'spec_helper_acceptance'

BASEDIR = default.tmpdir('ccs')

describe 'ccs_software class' do
  describe 'prepare host' do
    let(:manifest) do
      <<-PP
      user { ['ccs', 'ccsadm']:
        ensure     => 'present',
        managehome => true,
      }
      PP
    end

    it_behaves_like 'an idempotent resource'
  end

  context 'with trivial case without installations' do
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path => '#{BASEDIR}',
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(BASEDIR) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/lsst') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to BASEDIR }
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
      "#{BASEDIR}/ccs",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccs' }
        it { is_expected.to be_mode '1775' }
      end
    end

    [
      "#{BASEDIR}/ccsadm",
      "#{BASEDIR}/ccsadm/package-lists",
      "#{BASEDIR}/ccsadm/release",
      "#{BASEDIR}/ccsadm/scripts",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
        it { is_expected.to be_mode '755' } # serverspec does not like a leading 0
      end
    end

    # package deps
    %w[unzip git wget].each do |p|
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
      describe file("#{BASEDIR}/ccsadm/scripts/#{s}") do
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
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
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

    describe file(BASEDIR) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{BASEDIR}/ccs/comcam-software-2.2.7",
      "#{BASEDIR}/ccs/comcam-software-2.2.7/bin",
      "#{BASEDIR}/ccs/cb1f1e2",
      "#{BASEDIR}/ccs/cb1f1e2/bin",
      "#{BASEDIR}/ccsadm",
      "#{BASEDIR}/ccsadm/package-lists",
      "#{BASEDIR}/ccsadm/package-lists/comcam-software-2.2.7",
      "#{BASEDIR}/ccsadm/package-lists/comcam-software-2.2.7/.git",
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2",
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2/.git",
      "#{BASEDIR}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with complex installations' do
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
        installations => {
          test1 => {
            repo_path => "#{BASEDIR}/ccsadm/package-lists/test1.foo",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
          test42 => {
            repo_path => "#{BASEDIR}/ccsadm/package-lists/test42.bar",
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

    describe file(BASEDIR) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{BASEDIR}/ccs/test1",
      "#{BASEDIR}/ccs/test1/bin",
      "#{BASEDIR}/ccs/test42",
      "#{BASEDIR}/ccs/test42/bin",
      "#{BASEDIR}/ccsadm",
      "#{BASEDIR}/ccsadm/package-lists",
      "#{BASEDIR}/ccsadm/package-lists/test1.foo",
      "#{BASEDIR}/ccsadm/package-lists/test1.foo/.git",
      "#{BASEDIR}/ccsadm/package-lists/test42.bar",
      "#{BASEDIR}/ccsadm/package-lists/test42.bar/.git",
      "#{BASEDIR}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with shared git clones' do
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
        installations => {
          test-mcm => {
            repo_path => "#{BASEDIR}/ccsadm/package-lists/cb1f1e2",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'cb1f1e2',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
          test-fp => {
            repo_path => "#{BASEDIR}/ccsadm/package-lists/cb1f1e2",
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
      "#{BASEDIR}/ccsadm",
      "#{BASEDIR}/ccsadm/package-lists",
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2",
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2/.git",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    [
      "#{BASEDIR}/ccsadm/package-lists/test-mcm",
      "#{BASEDIR}/ccsadm/package-lists/test-fp",
    ].each do |d|
      describe file(d) do
        it { is_expected.not_to exist }
      end
    end
  end

  context 'with aliases' do
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
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
      "#{BASEDIR}/ccs/foo",
      "#{BASEDIR}/ccs/bar",
      "#{BASEDIR}/ccs/baz",
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{BASEDIR}/ccs/comcam-software-2.2.7" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    [
      "#{BASEDIR}/ccs/a",
      "#{BASEDIR}/ccs/b",
      "#{BASEDIR}/ccs/c",
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{BASEDIR}/ccs/cb1f1e2" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with etc symlink' do
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
        hostname      => 'comcam-fp01',
        env           => 'ComCam',
        installations => {
          'comcam-software-1.0.6' => {},
        },
      }
      PP
    end

    it_behaves_like 'an idempotent resource'

    describe file(BASEDIR) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{BASEDIR}/ccs/comcam-software-1.0.6",
      "#{BASEDIR}/ccs/comcam-software-1.0.6/bin",
      "#{BASEDIR}/ccsadm",
      "#{BASEDIR}/ccsadm/package-lists",
      "#{BASEDIR}/ccsadm/package-lists/comcam-software-1.0.6",
      "#{BASEDIR}/ccsadm/package-lists/comcam-software-1.0.6/.git",
      "#{BASEDIR}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    # symlink created by install.py
    describe file("#{BASEDIR}/ccs/comcam-software-1.0.6/etc") do
      it { is_expected.to be_symlink }
      # link is relative
      it { is_expected.to be_linked_to 'ccs-prod-configurations-comcam-software-1.0.6/ComCam/comcam-fp01' }
      it { is_expected.to be_owned_by 'ccsadm' }
      it { is_expected.to be_grouped_into 'ccsadm' }
    end

    [
      # symlink target dir
      "#{BASEDIR}/ccs/comcam-software-1.0.6/ccs-prod-configurations-comcam-software-1.0.6/ComCam/comcam-fp01",
      # package containing symlink target dir
      "#{BASEDIR}/ccs/comcam-software-1.0.6/ccs-prod-configurations-comcam-software-1.0.6",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccs' }
        it { is_expected.to be_grouped_into 'ccs' }
      end
    end

    # file in chown'd etc dir
    describe file("#{BASEDIR}/ccs/comcam-software-1.0.6/etc/comcam-fp_safe_DAQ.properties") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'ccs' }
      it { is_expected.to be_grouped_into 'ccs' }
    end
  end

  context 'with services' do
    let(:manifest) do
      <<-PP
      # java is only needed to start services
      $jdk_pkg = fact('os.release.major') ? {
        '7'     => 'java-1.8.0-openjdk-devel',
        default => 'java-17-openjdk-devel',
      }

      class { 'java':
        package => $jdk_pkg,
      }
      -> Class['ccs_software']

      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
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
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path => '#{BASEDIR}',
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
    let(:manifest) do
      <<-PP
      class { 'ccs_software':
        base_path     => '#{BASEDIR}',
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
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2",
      "#{BASEDIR}/ccsadm/package-lists/cb1f1e2/.git",
      "#{BASEDIR}/ccsadm/release",
      "#{BASEDIR}/ccsadm/release/.git",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end
end
