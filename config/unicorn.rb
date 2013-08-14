root = ENV['DB_PERF_TEST_ROOT'] || '/root/db_perf_test' #Rails project root
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen 8080
worker_processes 3
timeout 30
