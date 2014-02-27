# == Class: prefetch
#
# Prefetches document from various sources on the local machine.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { prefetch:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class prefetch(
  $home_dir = $prefetch::params::home_dir,
  $owner    = $prefetch::params::owner,
  $group    = $prefetch::params::group,
) inherits prefetch::params
{
  if ($::operatingsystem == 'Windows')
  {
    # We do not want to copy Unix modes to Windows, it tends to render files unaccessible
    File { source_permissions => ignore }
  }

  if (!defined(File[$home_dir]))
  {
    file {$home_dir:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => '0775',
    }
  }

  $prefetches = hiera_hash('prefetches', {})

  if (! empty($prefetches))
  {
    $prefetch_defaults = {
      ensure     => present,
      target_dir => $home_dir,
      owner      => $owner,
      group      => $group,
      mode       => '0644',
      timeout    => 900,
    }
    create_resources(prefetch::download, $prefetches, $prefetch_defaults)
  }

}
