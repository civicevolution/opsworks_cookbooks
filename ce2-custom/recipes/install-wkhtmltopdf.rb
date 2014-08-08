log "^^^^^^ Feb 18 10:55 custom recipe ce2-custom::install-wkhtmltopdf"

node[:deploy].each do |application, deploy|

  log "^^^^^^ Install wkhtmltopdf Feb 18 10:55 application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails' #|| node[:deploy][application][:rails_env] != 'production'
    log("Skipping ce2-custom::install-wkhtmltopdf for application #{application} as it is not a Rails app")
    next
  end

  wkhtmltopdf_dir = "/usr/local/bin"


  # download wkhtmltopdf
  remote_file "#{wkhtmltopdf_dir}/wkhtmltox-0.12.1.tar.bz2" do
    source "http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.1/wkhtmltox-0.12.1.tar.bz2"
    # old https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.0/wkhtmltox-linux-amd64_0.12.0-03c001d.tar.xz"
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    not_if { FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltox-0.12.1.tar.bz2") }
  end

  execute "unarchive wkhtmltopdf" do
    command "cd #{wkhtmltopdf_dir} && tar xvf wkhtmltox-0.12.1.tar.bz2 && sync"
    not_if { FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltox-0.12.1") }
  end

  execute "move wkhtmltopdf" do
    command "cd #{wkhtmltopdf_dir} && mv wkhtmltox/bin/wkhtmltopdf wkhtmltopdf"
    not_if { FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltopdf") }
  end

  execute "move wkhtmltoimage" do
    command "cd #{wkhtmltopdf_dir} && mv wkhtmltox/bin/wkhtmltoimage wkhtmltoimage"
    not_if { FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltoimage") }
  end

  execute "remove tar file for wkhtmltopdf" do
    command "cd #{wkhtmltopdf_dir} && rm -f wkhtmltox-0.12.1.tar.bz2"
    not_if { !FileTest.exists?("#{wkhtmltopdf_dir}/wkhtmltox-0.12.1.tar.bz2") }
  end

  execute "remove misc files for wkhtmltopdf" do
    command "cd #{wkhtmltopdf_dir} && rm -f -R wkhtmltox"
    not_if { !FileTest.directory?("#{wkhtmltopdf_dir}/wkhtmltox") }
  end

end