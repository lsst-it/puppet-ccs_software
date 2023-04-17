# frozen_string_literal: true

configure_beaker do |host|
  install_module_from_forge_on(host, 'puppetlabs/accounts', '> 7 < 8')
  install_module_from_forge_on(host, 'puppet/alternatives', '>= 4.1.0')
  install_module_from_forge_on(host, 'lsst/java_artisanal', '>= 2.4.0 < 3')
  scp_to(host, "#{__dir__}/../../fixtures/facts/site.yaml", '/opt/puppetlabs/facter/facts.d/site.yaml')
  # XXX this is a kludge!  We need to overwrite the first automatic
  # installation of the dev module as the `log` dir is being filtered out.
  install_module(ignore_list: ['.bundle', 'bundle', '.vendor', 'vendor'])
end
