# A Maestro master server with an agent in the same server

node 'master_with_agent' inherits 'master' {
  # Maestro agent
  include maestro_nodes::agentrvm
}
