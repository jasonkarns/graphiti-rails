namespace :graphiti do
  desc "Execute request without web server."
  task :request, [:path, :debug] => [:environment] do |_, args|
    require_relative "rake_helpers"
    extend Graphiti::Rails::RakeHelpers
    setup_rails!
    Graphiti.logger = Graphiti.stdout_logger
    Graphiti::Debugger.preserve = true
    require "pp"
    path, debug = args[:path], args[:debug]
    puts "Graphiti Request: #{path}"
    json = make_request(path, debug)
    pp json
    Graphiti::Debugger.flush if debug
  end

  desc "Execute benchmark without web server."
  task :benchmark, [:path, :requests] => [:environment] do |_, args|
    require_relative "rake_helpers"
    extend Graphiti::Rails::RakeHelpers
    setup_rails!
    took = Benchmark.ms {
      args[:requests].to_i.times do
        make_request(args[:path])
      end
    }
    puts "Took: #{(took / args[:requests].to_f).round(2)}ms"
  end
end
