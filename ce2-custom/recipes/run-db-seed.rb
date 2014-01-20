if File.exists?("#{ROOT_PATH}/current/db/seeds.rb")
  puts "OpsWorks: running rake db:seed with bundle exec"
  run_and_ignore_exitcode_and_print_command "cd #{ROOT_PATH}/current && /usr/local/bin/bundle exec rake db:seed"
else
  puts "OpsWorks: no db/seeds.rb file found - do not attempt to run it"
end
