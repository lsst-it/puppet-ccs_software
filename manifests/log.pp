#
# XXX is it possible to replace this script with a logrotate conf and a
# logging.properties that does not try to do its own log rotation?
#
# @summary
#   Create /var/log/ccs and install logrotation.
#
# @api private
class ccs_software::log {
  assert_private()

  $file = 'ccs-log-compress'

  # XXX convert site to be a mod param and pass this value in via profile
  # lint:ignore:top_scope_facts
  $archive = $::site ? { 'slac' => 'm', default => 'n', }
  # lint:endignore

  file { "/etc/cron.daily/${file}":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp("${module_name}/log/${file}", {'archive' => $archive}),
  }
}
