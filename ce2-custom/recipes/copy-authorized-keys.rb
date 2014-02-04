node[:deploy].each do |application, deploy|
  execute "Copy authorized_keys" do
    command "cp /home/ec2-user/.ssh/authorized_keys /home/#{deploy[:user]}/.ssh/authorized_keys"
    not_if { ::File.exists?("/home/#{deploy[:user]}/.ssh/authorized_keys") }
  end

  execute "Chown authorized_keys" do
    command "chown #{deploy[:user]} /home/#{deploy[:user]}/.ssh/authorized_keys"
  end
end