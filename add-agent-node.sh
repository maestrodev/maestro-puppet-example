#!/bin/sh

# Script to add an agent node to the puppet manifests.

AGENT_HOST=$1

# create nodes
cat > /etc/puppet/manifests/nodes/$AGENT_HOST.pp << EOF
node "$AGENT_HOST" inherits "agent" {}
EOF

