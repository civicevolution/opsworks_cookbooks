log "^^^^^^ v1-22-10:06 custom recipe ce2-custom::init-db"

node[:deploy].each do |application, deploy|

  log "^^^^^^ v1-22-10:06 application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails'
    log("Skipping ce2-custom::init-db for application #{application} as it is not a Rails app")
    next
  end

  log "Initialize the rails database for #{application}"
  username = node[:deploy][application][:database][:username]
  password = node[:deploy][application][:database][:password]
  postgres_password = node['postgresql']['password']['postgres']
  db_name = node[:deploy][application][:database][:database]
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

end


