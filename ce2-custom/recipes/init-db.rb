log "Initialize the database"

username = node[:deploy][:ce2_ver_1][:database][:username]
password = node[:deploy][:ce2_ver_1][:database][:password]
postgres_password = node['postgresql']['password']['postgres']
db_name = node[:deploy][:ce2_ver_1][:database][:database]
statement = %{psql -U postgres -c "SELECT * FROM pg_database"}
owner = username

execute "create-db-user-#{username}" do
  #command %{psql -U postgres postgres -c \"CREATE USER #{username} with ENCRYPTED PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
  command %{psql -U postgres postgres -c \"CREATE USER #{username} with PASSWORD '#{password}' CREATEDB NOCREATEUSER\"}
  not_if %{psql -U postgres -c "select * from pg_roles" | grep #{username}}
end

execute "create database for #{db_name}" do
  command %{psql -U postgres -c \"CREATE DATABASE #{db_name} OWNER #{owner}\"}
  not_if "#{statement} | grep #{db_name}"
end


# pg_last_xlog_receive_location() probably returns something once the db has been in use
execute "alter-db-user-postgres" do
  command %{psql -U postgres -c \"ALTER USER postgres with ENCRYPTED PASSWORD '#{postgres_password}'\"}
  not_if %{psql -c "select pg_last_xlog_receive_location()" | grep "/"}
end

