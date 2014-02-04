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
#  core::download {"http://download.site.com/file-1.1.1.tar.bz2":
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
  validate_re($ensure, ['^(present|absent)$'])

  debug "Download[${name}]: source=${source}, target_dir=${target_dir}"
}
