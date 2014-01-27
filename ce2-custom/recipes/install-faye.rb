#
# Cookbook Name:: ce2-custom
# Recipe:: install-faye
#
# Install and start Juggernaut server
#
# IMPORTANT: This has to run AFTER opsworks_nodejs is run

# redis is on the same machine as db


faye_directory = '/opt/faye'
faye_server = "#{faye_directory}/server-redis.js"
pid_directory = '/var/run/faye'
faye_port = 8000
redis_host = "localhost" # get from stack json
redis_port = 6379

faye_user = 'deploy'
node_path = "/usr/local/bin/node"
faye_log_with_path = "/srv/www/ce2_ver_1/shared/log/faye-server-redis.log"


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
# cd /opt/faye
# npm install faye

execute "npm install faye" do
  command "cd faye_directory && npm install faye"
  not_if { ::File.directory?("#{faye_directory}/node_modules/#{faye}") }
end

# npm install faye-redis

execute "npm install faye-redis" do
  command "cd faye_directory && npm install faye-redis"
  not_if { ::File.directory?("#{faye_directory}/node_modules/#{faye-redis}") }
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
template "/etc/init/faye" do
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


=begin
#
# Modify /etc/nginx/sites-available/ce2_ver_1
# Add upstream block
# Add location /faye block

# Find next line(s) that starts with server
# and retrieve the host
# create a fragment from the template, with the host in it
# insert the fragment right after the commented out server line


filepath_haproxy_frag = "/etc/haproxy.frag.cfg"
filepath_haproxy = "/etc/haproxy.cfg"

# Don't process haproxy.cfg if it already has backend nodejs_server
haproxy = IO.read(filepath_haproxy)

if !haproxy.match(/nodejs_server/)
  Chef::Log.info "Yes, I need to process haproxy.cfg"
  # first create the fragement I will need
  # then read it into a variable to insert into the actual haproxy.cfg
  template filepath_haproxy_frag do
    source "haproxy.cfg.frag.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
                  :master_app_server_host => master_app_server_host,
                  :node_js_port => node_js_port
              })
  end

  ruby_block "insert the nodejs compliant front end into haproxy" do
    block do
      haproxy_frag = IO.read(filepath_haproxy_frag)
      File.open(filepath_haproxy, "w") do |file|
        haproxy.split(/\n/).each do |line|
          if line.match(/listen\s*cluster\s*:80/i)
            file.puts "# #{line}"
            file.puts "###################\n# Custom code inserted by Chef to route realtime to nodejs\n"
            file.puts haproxy_frag
          else
            file.puts line
          end
        end
      end # end file
    end # block
    action :create
  end # ruby_block

  execute "Restart haproxy" do
    command %Q{
            /etc/init.d/haproxy reload
          }
    only_if { FileTest.exists?(filepath_haproxy_frag) }
  end

  execute "Delete the cfg frag" do
    command "rm #{filepath_haproxy_frag}"
  end
end
=end


# sudo su deploy
# cd /opt/faye
# node server-redis.js
#


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


=begin
# do I need an init.d file to run through monit?
# install init.d
template "/etc/init.d/juggernaut" do
  source "juggernaut.init.d.erb"
  owner "root"
  group "root"
  mode 0755
  variables({
    :pid_file => pid_file,
    :redis_host => redis_host,
    :redis_port => redis_port,
    :redis_user => redis_user,
    :redis_pwd => redis_pwd,
    :log_file => log_file
  })
end
=end

=begin
execute "monit reload" do
  action :run
end
=end

