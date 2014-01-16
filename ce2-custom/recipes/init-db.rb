#include_recipe "openssl"
#include_recipe "postgresql::server"
#include_recipe "database::postgresql"

log "Hey this is my custom recipe"

log "message" do
  message "This is the message that will be added to the log AS A WARNING."
  level :warn
end

log "password is #{ node['postgresql']['password']['postgres'] }"

log "^^^^^^ Damnit, just create the user myself"

=begin

postgresql_connection_info = {
    :host     => 'localhost',
    :port     => node['postgresql']['config']['port'],
    :username => 'postgres',
    :password => node['postgresql']['password']['postgres']
}



# Create a postgresql user but grant no privileges
postgresql_database_user 'disenfranchised' do
  connection postgresql_connection_info
  password   'super_secret'
  action     :create
end



postgresql_database 'foo' do
  connection postgresql_connection_info
  action     :create
end


# Drop a database
mysql_database 'baz' do
  connection mysql_connection_info
  action    :drop
end
=end