# \ -s puma -E production

require 'faye'

Dir.glob('./{controllers,services,forms,values,workers}/*.rb')
  .each do |file|
  require file
end

use Faye::RackAdapter, mount: '/faye', timeout: 3000
run GradCafeVisualizationApp
