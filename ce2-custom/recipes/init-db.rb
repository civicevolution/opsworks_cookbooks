log "Initialize the database"

log "message" do
  message "password is #{ node['postgresql']['password']['postgres'] }"
  level :warn
end

username = node[:deploy][:ce2_test][:database][:username]

log "create the user: #{username}"

log "create the database"

log "add the extension"

=begin
db_name = params[:name].downcase
statement = %{psql -U postgres -h localhost -c "SELECT * FROM pg_database"}
owner = params[:owner]

execute "create database for #{db_name}" do
  command %{psql -U postgres postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
  not_if "#{statement} | grep #{db_name}"
end


execute "create-db-user#{username}" do
  log "create-db-user"
  #command  %{psql -U postgres postgres -c \"CREATE USER #{username} with ENCRYPTED PASSWORD '#{password}' createdb\"}
  #not_if %{psql -U postgres -c "select * from pg_roles" | grep #{username}}
end

execute "alter-db-user-postgres" do
  log "alter-db-user-postgres"
  #command %{psql -Upostgres postgres -c \"ALTER USER postgres with ENCRYPTED PASSWORD '#{password}'\"}
  #not_if %{psql -c "select pg_last_xlog_receive_location()" | grep "/"}
end

execute "alter-public-schema-owner-to-#{node[:owner_name]}" do
  log "alter-public-schema-owner-to-"
  #command %{psql -U postgres postgres -c \"ALTER SCHEMA public OWNER TO #{node[:owner_name]}\"}
  #not_if %{psql -c "select pg_last_xlog_receive_location()" | grep "/"}
end
=end

=begin

postgresql_connection_info = {
    :host     => 'localhost',
    :port     => node['postgresql']['config']['port'],
    :username => 'postgres',
    :password => node['postgresql']['password']['postgres']
}
=end