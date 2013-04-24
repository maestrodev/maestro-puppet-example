# A Maestro Agent node with git, subversion, maven, ant,...

node 'agent' inherits 'parent' {
  # Maestro agent
  include maestro_nodes::agent
  include maestro::test::dependencies
  include maestro_nodes::agentrvm
}
