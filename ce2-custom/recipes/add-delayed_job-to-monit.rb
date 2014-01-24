node[:deploy].each do |application, deploy|

  log "^^^^^^ v1-22-22:57 add-delayed_job-to-monit application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails'
    log("Skipping ce2-custom::add-delayed_job-to-monit for application #{application} as it is not a Rails app")
    next
  end

  directory "/var/run/delayed_job/#{application}" do
    recursive true
    owner "deploy"
    group "nobody"
    mode 0755
    not_if { ::File.directory?("/var/run/delayed_job/#{application}") }
  end

  template "/etc/monit.d/delayed_job.#{application}.monitrc" do
    source "delayed_job.monitrc.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
                  :app_name => application,
                  :owner => 'deploy',
                  :worker_name => "delayed_job_#{application}"
              })
    not_if { ::File.exists?("/etc/monit.d/delayed_job.#{application}.monitrc") }
  end
end

