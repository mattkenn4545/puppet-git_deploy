define git_deploy::project {
  include git_deploy

  $project_path = $git_deploy::project_path

  file { "${project_path}/${name}.git":
    ensure => directory,
    mode    => '0750',
    owner   => 'git',
    group   => 'git',
    require => [ User[ 'git' ], File[$project_path] ],
  } ->

  exec { "${name} git --bare init":
    cwd     => "${project_path}/${name}.git",
    creates => "${project_path}/${name}.git/description",
    user    => 'git',
    command => 'git --bare init',
    require => Package[ 'git' ]
  }
}
