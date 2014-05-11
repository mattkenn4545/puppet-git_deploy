class git_deploy (
  $key            = false,
  $project_path   = '/opt/projects'
) {
  include stdlib

  ensure_packages(['git'])

  user { 'git':
    ensure      => present,
    managehome  => true,
    home        => '/home/git/'
  } ->

  file { '/home/git/.ssh':
    ensure      => directory,
    mode        => '0750',
    owner       => 'git',
    group       => 'git',
    require     => User[ 'git' ]
  }

  if $key {
    ssh_authorized_key { 'deploy':
      ensure      => present,
      type        => 'ssh-rsa',
      key         => $key,
      user        => 'git',
      require     => File[ '/home/git/.ssh' ]
    }
  }

  file { $project_path:
    ensure      => directory,
    mode        => '0750',
    owner       => 'git',
    group       => 'git',
    require     => User[ 'git' ]
  }

  file { '/var/log/git_deploy':
    ensure      => directory,
    mode        => '0755',
    owner       => 'git',
    group       => 'git',
    require     => User[ 'git' ]
  }
}
