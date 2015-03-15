#
# Cookbook Name:: ce2-custom
# Recipe:: install-faye
#
# Install and start Juggernaut server
#
# IMPORTANT: This has to run AFTER opsworks_nodejs is run

# redis is on the same machine as db

app_name = "ce2_ver_1" # get this from stack json
faye_directory = '/opt/faye'
faye_server = "#{faye_directory}/server-redis.js"
faye_port = 8000
redis_host = "localhost" # get from stack json
redis_port = 6379

faye_user = 'deploy'
node_path = "/usr/local/bin/node"
faye_log_with_path = "/srv/www/#{app_name}/shared/log/faye-server-redis.log"


#pid_directory = '/var/run/faye'
#pid_file = '/var/run/faye/faye.pid'
#log_file = '/var/log/engineyard/juggernaut.log'
#chef_file = '/etc/chef/dna.json'
#chef_config = JSON.parse(File.read(chef_file))
#master_app_server_host = chef_config['master_app_server']['public_ip']
#node_js_port = 8080

#redis_host = 'http://brian:123@ec2-50-18-101-127.us-west-1.compute.amazonaws.com:6379'

# Install nodejs & npm using recipe opsworks_nodejs::default

# Create a directory where I want to run Faye

directory faye_directory do
  recursive true
  owner "deploy"
  group "nobody"
  mode 0755
  not_if { ::File.directory?(faye_directory) }
end

#
# Install Faye

npm_package "faye" do
  #version "1.0.1"
  path faye_directory
  action :install_local
end

npm_package "faye-redis" do
  path faye_directory
  action :install_local
end


#
# Add my server-redis.js file
#

template "#{faye_server}" do
  source "server-redis.js.erb"
  owner "deploy"
  group "root"
  mode 0755
  variables({
                :faye_port => faye_port,
                :redis_host => redis_host,
                :redis_port => redis_port
            })
end


# Run from upstart script
template "/etc/init/faye.conf" do
  source "faye.upstart.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
                :faye_user => faye_user,
                :node_path => node_path,
                :faye_server => faye_server,
                :faye_log_with_path => faye_log_with_path
            })
end


#
# Modify /etc/nginx/sites-available/ce2_ver_1
# Add upstream block
# Add location /faye block

# Find next line(s) that starts with server
# and retrieve the host
# create a fragment from the template
# insert the fragment

nginx_conf_path = "/etc/nginx/sites-available"
filepath_nginx_conf = "#{nginx_conf_path}/#{app_name}"

#Chef::Log.info "^^^^^^^^^^^^^^^ check for file: #{filepath_nginx_conf}"


if ::File.exists?(filepath_nginx_conf)
  faye_upstream_frag_file = "#{nginx_conf_path}/upstream.frag"
  faye_location_frag_file = "#{nginx_conf_path}/location.frag"

  nginx_conf = IO.read(filepath_nginx_conf)
  add_upstream = !nginx_conf.match(/upstream faye_upstream/)
  add_location = !nginx_conf.match(/location \/faye/)

  # if the file has previously been modified, it will be reset by chef
  # so I need to update the file each time deploy is run
  # Note, the modifications aren't run till near the end of deploy, but these tests are run much earlier
  #add_upstream = add_location = true

  Chef::Log.info "add_upstream: #{add_upstream}, add_location: #{add_location}"

  #Chef::Log.info "File: #{filepath_nginx_conf} is #{nginx_conf}"

  if add_upstream
    Chef::Log.info "Yes, I need to add faye_upstream to #{filepath_nginx_conf}"

    # create frags for upstream and location
    template faye_upstream_frag_file do
      source "upstream.frag.erb"
      owner "root"
      group "root"
      mode 0644
    end

    ruby_block "insert the nodejs compliant upstream into nginx" do
      block do
        upstream_frag = IO.read(faye_upstream_frag_file)
        nginx_conf = IO.read(filepath_nginx_conf)
        File.open(filepath_nginx_conf, "w") do |file|
          nginx_conf.split(/\n/).each do |line|
            if line.match(/\A\s*upstream\s/i)
              file.puts "###################\n# Custom upstream inserted by Chef to route faye to nodejs\n"
              file.puts upstream_frag
            end
            file.puts line
          end
        end # end file
      end # block
      action :create
    end # ruby_block

    execute "Delete the upstream frag" do
      command "rm #{faye_upstream_frag_file}"
    end
  end


  if add_location
    Chef::Log.info "Yes, I need to add faye_location to #{filepath_nginx_conf}"

    # create frags for location
    template faye_location_frag_file do
      source "location.frag.erb"
      owner "root"
      group "root"
      mode 0644
    end

    ruby_block "insert the nodejs compliant location into nginx" do
      block do
        location_frag = IO.read(faye_location_frag_file)
        nginx_conf = IO.read(filepath_nginx_conf)
        File.open(filepath_nginx_conf, "w") do |file|
          nginx_conf.split(/\n/).each do |line|
            if line.match(/\A\s*location\s+\/[\s\{]/i)
              file.puts "###################\n# Custom location inserted by Chef to route faye to nodejs\n"
              file.puts location_frag
            end
            file.puts line
          end
        end # end file
      end # block
      action :create
    end # ruby_block

    execute "Delete the location frag" do
      command "rm #{faye_location_frag_file}"
    end
  end

  execute "Restart nginx" do
    command "/etc/init.d/nginx reload"
    only_if { add_upstream || add_location }
  end
end

execute "Start faye" do
  command "start faye"
  not_if("ps aux | grep faye/server-redis.js | grep -v grep | grep -v sudo")
end

=begin
#create pidfile directory
directory pid_directory do
  recursive true
  owner "deploy"
  group "nobody"
  mode 0755
  not_if { ::File.directory?(pid_directory) }
end
=end

=begin
# create monit script
# add to monit
case node[:instance_role]
  when "solo", "app_master"
    template "/etc/monit.d/juggernaut.monitrc" do
      source "juggernaut.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
      variables({
                    :pid_file => pid_file
                })
    end
end
=end

=begin
execute "monit reload" do
  action :run
end
=end


=begin
# add log_rotate
  template "/etc/logrotate.d/juggernaut" do
    source "juggernaut.logrotate.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :pid_file => pid_file,
      :log_file => log_file
    })
  end
=end

=begin
# do I need a symlink?
  execute "symlink juggernaut" do
    # create a sym link to juggernuat
    command "ln -sfv /opt/nodejs/bin/juggernaut /usr/local/bin"
    not_if { FileTest.exists?("/usr/local/bin/juggernaut") }
  end
=end




