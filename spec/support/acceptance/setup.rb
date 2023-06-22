# frozen_string_literal: true

configure_beaker(modules: :fixtures) do |host|
  scp_to(host, "#{__dir__}/../../fixtures/facts/site.yaml", '/opt/puppetlabs/facter/facts.d/site.yaml')
end
