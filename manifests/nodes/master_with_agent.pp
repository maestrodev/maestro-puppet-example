# A Maestro master server with an agent in the same server

node 'master_with_agent' inherits 'master' {
  include maestro::repository

  # Maestro agent
  class { 'maestro_nodes::agent':
    repo => $maestro::repository::maestrodev,
  }

  # Maestro demo compositions
  class { 'maestro_demo': }

  include maestro::test::dependencies
}
