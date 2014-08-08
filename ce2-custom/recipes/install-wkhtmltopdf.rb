log "^^^^^^ Feb 18 10:55 custom recipe ce2-custom::install-wkhtmltopdf"

node[:deploy].each do |application, deploy|

  log "^^^^^^ Install wkhtmltopdf Feb 18 10:55 application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails' #|| node[:deploy][application][:rails_env] != 'production'
    log("Skipping ce2-custom::install-wkhtmltopdf for application #{application} as it is not a Rails app")
    next
  end

  wkhtmltopdf_dir = "/usr/local/bin"

  # download wkhtmltopdf
  remote_file "#{wkhtmltopdf_dir}/wkhtmltox-0.12.1_linux-centos6-amd64.rpm" do
    source "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1_linux-centos6-amd64.rpm"
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    not_if { FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltox-0.12.1_linux-centos6-amd64.rpm") }
  end

  rpm_package "wkhtmltox" do
    source "#{wkhtmltopdf_dir}/wkhtmltox-0.12.1_linux-centos6-amd64.rpm"
    action :install
    not_if { ::File.exists?("/usr/local/bin/wkhtmltopdf") }
  end


end