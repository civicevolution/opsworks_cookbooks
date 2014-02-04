#node[:deploy].each do |application, deploy|
# can I get #{deploy[:user]} instead of hardcoding "deploy"
execute "Copy authorized_keys" do
  command "cp /home/ec2-user/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys"
  not_if { ::File.exists?("/home/deploy/.ssh/authorized_keys") }
end

  execute "Chown authorized_keys" do
    command "chown deploy /home/deploy/.ssh/authorized_keys"
  end
#end