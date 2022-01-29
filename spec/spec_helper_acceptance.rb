# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'git')
  install_module_from_forge_on(host, 'puppetlabs/accounts', '> 7 < 8')
  scp_to(host, "#{__dir__}/fixtures/facts/site.yaml", '/opt/puppetlabs/facter/facts.d/site.yaml')
  # XXX this is a kludge!  We need to overwrite the first automatic
  # installation of the dev module as the `log` dir is being filtered out.
  install_module(ignore_list: ['.bundle', 'bundle', '.vendor', 'vendor'])
  clone_git_repo_on(host, '/etc/puppetlabs/code/environments/production/modules',
                    name: 'java_artisanal',
                    path: 'https://github.com/lsst-it/puppet-java_artisanal',
                    rev: 'master')
  # java_artisanal deps
  {
    'puppetlabs/accounts' => '> 1',
    'puppet/yum' => '>= 4 < 6',
    'puppet/alternatives' => '> 3 < 5',
  }.each do |mod, rev|
    install_module_from_forge_on(host, mod, rev)
  end
end

shared_examples 'an idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end
