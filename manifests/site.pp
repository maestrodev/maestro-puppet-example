hiera_include(classes, [""])

import '../modules/maestro_nodes/manifests/nodes/*.pp'
import 'nodes/*.pp'
import 'nodes/default/*.pp'
