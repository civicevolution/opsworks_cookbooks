yum_package "ImageMagick" do
  action :install
  not_if { ::File.exists?("/usr/bin/convert") }
end
