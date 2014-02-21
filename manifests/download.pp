# == Define: download
#
# download defined type to fetch files from a URL.
#
# === Parameters
#
# [*source*]
#   This represents a URL that tells where to find what we want to download.
#   This parameter defaults to the namevar.
#
# [*target_dir*]
#   The target directory where the downloaded data will be stored.
#   This parameter defaults to @see $core::cache_dir
#
# [*md5*]
#   If present, this parameter contains the MD5 hash of the file to download.
#   The MD5 from the URL (downloaded first) will be compared to this parameter.
#   If found equal, $source is not downloaded.
#
# [*owner*]
#   The optional owner of the downloaded data.
#   Note: ignored on Windows.
#
# [*group*]
#   The optional group of the downloaded data.
#   Note: ignored on Windows.
#
# [*mode*]
#   The optional octal mode of the downloaded data.
#
# [*ensure*]
#   This tells if we should download the source (present)
#    or remove from the target directory (absent)
#
# [*timeout*]
#   How long before the download (Exec resource) will timeouts
#   defaults to 5 minutes
#
# === Examples
#
#  prefetch::download {"http://download.site.com/file-1.1.1.tar.bz2":
#    target_dir => '/tmp',
#    owner      => root,
#    group      => wheel,
#  }
#
# === Authors
#
# Gildas CHERRUEL <gildas@breizh.org>
#
# === Copyright
#
# Copyright 2014 (c) Gildas Cherruel
#
define prefetch::download(
  $source     = $name,
  $ensure     = present,
  $target_dir = $core::cache_dir,
  $md5        = undef,
  $owner      = undef,
  $group      = undef,
  $mode       = undef,
  $timeout    = 300,
)
{
    # TODO: 
    # Support several sources, like:
    # source => [ "first URL", "Second URL" ],
    # First is tried first and if it fails, Second is used.
    # That way we could have a closer server for the file, and a backup at Microsoft.
    # To download 2008R2 from Microsoft took 4 hours...
  validate_re($ensure, ['^(present|absent)$'])

  if ($::operatingsystem == 'Windows')
  {
    # We do not want to copy Unix modes to Windows, it tends to render files unaccessible
    File { source_permissions => ignore }
  }

  debug "Download[${name}]: source=${source}, target_dir=${target_dir}"
  $filename = url_parse($source, 'filename')

  if (! defined(File[$target_dir]))
  {
    file {$target_dir:
      ensure => directory,
      mode   => $mode,
    }
  }

  case ($ensure)
  {
    present:
    {
      case $::operatingsystem
      {
        'Windows':
        {
          exec {"download-${filename}":
            command  => "((new-object net.webclient).DownloadFile('${source}','${target_dir}/${filename}'))",
            creates  => "${target_dir}/${filename}",
            timeout  => $timeout,
            provider => powershell,
            require  => File[$target_dir],
          }

          # owner cannot be easily set on Windows
        }
        'Darwin':
        {
          # curl is always installed on Mac OS/X
          $curl_bin  = '/usr/bin/curl'
          $curl_args = '--silent --show-error --fail --insecure --location'
          exec {"download-${filename}":
            command => "${curl_bin} ${curl_args} --output \"${target_dir}/${filename}\" \"${source}\"",
            creates => "${target_dir}/${filename}",
            timeout => $timeout,
            require => File[$target_dir],
          }

          if ($owner != undef)
          {
            exec {"chown-${filename}":
              command => "/usr/sbin/chown ${owner}:${group} \"${target_dir}/${filename}\"",
              unless  => "/bin/test `/usr/bin/stat -f %Su '${target_dir}/${filename}'` = \"${owner}\" ",
              timeout => $timeout,
              require => Exec["download-${filename}"],
            }
          }

          if ($mode != undef)
          {
            exec {"chmod-${filename}":
              command => "/bin/chmod ${mode} \"${target_dir}/${filename}\"",
              unless  => "/bin/test \"0`/usr/bin/stat -f %OLp '${target_dir}/${filename}'`\" = \"${mode}\" ",
              timeout => $timeout,
              require => Exec["download-${filename}"],
            }
          }
        }
        'Linux':
        {
          # TODO: We should check curl is installed!
          $curl_bin  = '/usr/bin/curl'
          $curl_args = '--silent --show-error --fail --insecure --location'
          exec {"download-${filename}":
            command => "${curl_bin} ${curl_args} --output \"${target_dir}/${filename}\" \"${source}\"",
            creates => "${target_dir}/${filename}",
            timeout => $timeout,
            require => File[$target_dir],
          }

          if ($owner != undef)
          {
            exec {"chown-${filename}":
              command => "/bin/chown ${owner}:${group} \"${target_dir}/${filename}\"",
              unless  => "/usr/bin/test `/usr/bin/stat -C %U '${target_dir}/${filename}'` = \"${owner}\" ",
              timeout => $timeout,
              require => Exec["download-${filename}"],
            }
          }
          if ($mode != undef)
          {
            exec {"chmod-${filename}":
              command => "/bin/chmod ${mode} \"${target_dir}/${filename}\"",
              unless  => "/usr/bin/test \"0`/usr/bin/stat -c %a '${target_dir}/${filename}'`\" = \"${mode}\" ",
              timeout => $timeout,
              require => Exec["download-${filename}"],
            }
          }
        }
        default: { fail("Unsupported Operating System value: \"${::operatingsystem}\"") }
      }
    }
    absent:
    {
      file {"remove-${filename}.md5":
        ensure => absent,
        path   => "${target_dir}/${filename}.md5",
        purge  => true,
        force  => true,
      }
      file {"remove-${filename}":
        ensure => absent,
        path   => "${target_dir}/${filename}",
        purge  => true,
        force  => true,
      }
    }
    default: { fail("Unsupported ensure value: \"${ensure}\"") }
  }
}
