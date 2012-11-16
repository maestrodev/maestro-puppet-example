# A Maestro Agent node with git, subversion, maven, ant,...

node 'agent' inherits 'parent' {
  include maestro::repository

  include maestro_nodes::repositories

  # Maestro agent
  class { 'maestro_nodes::agent':
    repo => $maestro::repository::maestrodev,
  }
}
