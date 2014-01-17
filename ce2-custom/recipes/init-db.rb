log "Initialize the database"


username = node[:deploy][:ce2_test][:database][:username]
password = node[:deploy][:ce2_test][:database][:password]
postgres_password = node['postgresql']['password']['postgres']
db_name = node[:deploy][:ce2_test][:database][:database]
statement = %{psql -U postgres -h localhost -c "SELECT * FROM pg_database"}
owner = username

log "create the user: #{username}"
execute "create-db-user-#{username}" do
  command %{psql -U postgres postgres -c \"CREATE USER #{username} with ENCRYPTED PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
  not_if %{psql -U postgres -c "select * from pg_roles" | grep #{username}}
end

log "create the database"
execute "create database for #{db_name}" do
  command %{psql -U postgres postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
  not_if "#{statement} | grep #{db_name}"
end

execute "alter-db-user-postgres" do
  log "alter-db-user-postgres"
  command %{psql -U postgres postgres -c \"ALTER USER postgres with ENCRYPTED PASSWORD '#{postgres_password}'\"}
  not_if %{psql -c "select pg_last_xlog_receive_location()" | grep "/"}
end


log "add the extension TBD"

