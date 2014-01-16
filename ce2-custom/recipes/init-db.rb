message "Hey this is my custom recipe"

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
=END