# A Maestro Agent node with git, subversion, maven, ant,...

node 'agent' inherits 'parent' {
  # Declare before RVM to avoid conflicts
  include wget

  # Maestro agent
  include maestro::test::dependencies
  include maestro_nodes::agentrvm
}
