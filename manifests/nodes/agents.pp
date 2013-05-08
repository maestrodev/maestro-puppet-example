# Any node with hostname like *agent* is a maestro agent
node /.*agent.*/ inherits 'agent' {
  notify { "Using maestro master at ${maestro::agent::stomp_host}": } 
}
