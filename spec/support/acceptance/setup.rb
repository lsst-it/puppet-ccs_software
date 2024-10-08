# frozen_string_literal: true

configure_beaker(modules: :metadata) do |host|
  scp_to(host, "#{__dir__}/../../fixtures/facts/site.yaml", '/opt/puppetlabs/facter/facts.d/site.yaml')
  install_puppet_module_via_pmt_on(host, 'puppet/alternatives', '5')
  install_puppet_module_via_pmt_on(host, 'puppetlabs/java', '10')
  install_puppet_module_via_pmt_on(host, 'puppetlabs/concat', '9')
end
