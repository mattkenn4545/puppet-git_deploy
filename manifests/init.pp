class git_deploy (
  $project_path     = '/opt/projects'
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
  } ->

  ssh_authorized_key { 'matt':
    ensure      => present,
    type        => 'ssh-rsa',
    key         => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCzTy59LkeFxmZHnKVo0sJ3cfhFsOYCzqqr03uVjY77lhLPUPVjT6XImVBVvvJ+OX5J6yzk1YIObLVCcdEx+aSmL5rsQSrXferWuOKiv4bfb8rpMjUK04MIhBj8ZKI61Dah3VceUO33Q2VcH8XAhmQb0kUstd3GYcloh+pWEWVEo2WmT3+e9hI5/f4LpC6VkiEY1Rt0y51mFiljj62sedkFsjNAdNE6mWly/k03fEVtSRc74W/Y7clt74Z6LIYlTZnp9fhi9p7iI5zYHv9xoL5m1d2bRCJSXtBfFmuR2cdf1B5kcPJEnA5zpNLKQpY0lLhruJye9Slh5etn2v3wZdJP',
    user        => 'git'
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
