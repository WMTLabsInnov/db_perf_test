root = ENV['DYNAMIC_DEALS_ROOT'] || '/Users/vhuang2/work/flash_deal' #Rails project root
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen 8080
worker_processes 8
timeout 30
