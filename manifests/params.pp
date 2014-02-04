class prefetch::params
{
  case $::kernel
  {
    'Linux':
    {
      $home_dir = '/var/lib/puppet/cache'
      $owner    = 'puppet'
      $group    = 'puppet'
    }
    'Windows':
    {
      $home_dir = 'C:/ProgramData/PuppetLabs/puppet/var/cache'
      $owner    = 'puppet'
      $group    = undef
    }
    'Darwin':
    {
      $home_dir = '/var/lib/puppet/cache'
      $owner    = 'puppet'
      $group    = 'puppet'
    }
    default: { fail ("Unsupported kernel: ${::kernel}") }
  }
}
