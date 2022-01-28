# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'git')
  install_module_from_forge_on(host, 'puppetlabs/accounts', '> 7 < 8')
  scp_to(host, "#{__dir__}/fixtures/facts/site.yaml", '/opt/puppetlabs/facter/facts.d/site.yaml')
  # XXX this is a kludge!  We need to overwrite the first automatic
  # installation of the dev module as the `log` dir is being filtered out.
  install_module(ignore_list: ['.bundle', 'bundle', '.vendor', 'vendor'])
end

shared_examples 'an idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end
