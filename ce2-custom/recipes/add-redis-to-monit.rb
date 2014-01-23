node[:redisio][:server].each do |server|

  port = server[:port]

  log "^^^^^^ v1-22-22:57 add-redis-to-monit application: #{port}"

  directory "/var/run/redis/#{port}" do
    recursive true
    owner "redis"
    group "redis"
    mode 0755
  end

  template "/etc/monit.d/redis_#{port}.monitrc" do
    source "redis.monitrc.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
                  :port => port
              })
  end
end

