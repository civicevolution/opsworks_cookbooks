log "^^^^^^ Feb 5 14:16 custom recipe ce2-custom::create-database-yml"

node[:deploy].each do |application, deploy|

  log "^^^^^^ Feb 5 14:16 application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails' #|| node[:deploy][application][:rails_env] != 'production'
    log("Skipping ce2-custom::init-db for application #{application} as it is not a Rails app")
    next
  end

  template "#{node[:deploy][application][:deploy_to]}/shared/config/database.yml.custom" do
    cookbook "rails"
    source "database.yml.erb"
    mode "0660"
    owner node[:deploy][application][:user]
    group node[:deploy][application][:group]
    variables(
        :database => node[:deploy][application][:database],
        :environment => node[:deploy][application][:rails_env]
    )
  end.run_action(:create)
end