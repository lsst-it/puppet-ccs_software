#
# @summary
#   Install ccs software prerequisites
#
# @api private
class ccs_software::pre {
  assert_private()

  $deps = [
    'unzip',
    'git',
    'python3',
    'wget',
  ]

  ensure_packages($deps)
}
