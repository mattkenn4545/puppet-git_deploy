define git_deploy::project (
  $destination,
  $git_user_group = undef
) {
  include git_deploy

  $project_path       = $git_deploy::project_path
  $full_project_path  = "${project_path}/${name}.git"

  if !(defined(File [ $destination ])) {
    file { $destination:
      ensure    => directory
    }
  }

  File <| title == $destination |> {
    mode        => '0770',
    group       => $git_user_group ? {
                    undef     => 'root',
                    default   => $git_user_group }
  }

  if ($git_user_group) {
    User <| title == 'git' |> {
      groups      => [ $git_user_group ]
    }
  }

  User[ 'git' ] ->
  exec { "${name} git init":
    cwd         => $destination,
    creates     => "${destination}/.git",
    user        => 'git',
    command     => 'git init',
    require     => [ Package[ 'git' ], File [ $destination ] ]
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

  if (defined('auto_jenkin')) {
    @@auto_jenkin::build_step{ "${hostname}-${name}-deploy":
      job         => "${hostname}-${name}",
      command     => template("${module_name}/build_step-deploy.erb")
    }
  }
}
