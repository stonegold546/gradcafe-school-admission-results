# \ -s puma

Dir.glob('./{controllers,services,values,forms,workers}/*.rb')
  .each do |file|
  require file
end

use Faye::RackAdapter, mount: '/faye', timeout: 25
run GradCafeVisualizationApp
