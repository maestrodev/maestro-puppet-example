hiera_include(classes, [""])

# Default path for resources that don't set it: camptocamp/postfix, camptocamp/augeas,...
Exec {
  path => ['/usr/local/sbin','/usr/local/bin','/sbin','/bin','/usr/sbin','/usr/bin'],
}

import '../modules/maestro_nodes/manifests/nodes/*.pp'
import 'nodes/*.pp'
import 'nodes/default/*.pp'
