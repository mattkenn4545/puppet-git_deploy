define git_deploy::project (
  $destination,
  $git_user_groups = []
) {
  include git_deploy

  $project_path       = $git_deploy::project_path
  $full_project_path  = "${project_path}/${name}.git"

  File <| title == $destination |> {
    mode        => '0770'
  }

  User <| title == 'git' |> {
    groups      => $git_user_groups
  }

  User[ 'git' ] ->
  exec { "${name} git init":
    cwd         => $destination,
    creates     => "${destination}/.git",
    user        => 'git',
    command     => 'git init',
    require     => Package[ 'git' ]
  } ~>
  exec { "${name} git remote add":
    cwd         => $destination,
    user        => 'git',
    command     => "git remote add origin ${full_project_path}",
    refreshonly => true
  }

  User[ 'git' ] ->
  file { $full_project_path:
    ensure => directory,
    mode        => '0750',
    owner       => 'git',
    group       => 'git',
    require     => File[ $project_path ]
  } ->
  exec { "${name} git --bare init":
    cwd         => $full_project_path,
    creates     => "${full_project_path}/description",
    user        => 'git',
    command     => 'git --bare init',
    require     => Package[ 'git' ]
  } ->
  file { "${full_project_path}/hooks/post-receive":
    ensure      => present,
    mode        => '0750',
    owner       => 'git',
    group       => 'git',
    content     => template("${module_name}/post-receive")
  }
}
