yum_package "ImageMagick-devel" do
  action :install
  not_if { ::File.exists?("/usr/bin/Magick-config") }
end
