# Any node with hostname like *agent* is a maestro agent
node /.*agent.*/ inherits 'agent' {}
