name "ce2-custom"
maintainer "CivicEvolution"
maintainer_email "info@civicevolution.org"
license "Apache 2.0"
description "Custom config for CE2"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version "0.0.1"
recipe "ce2-custom::init-db", "DB initialization"

depends "npm"
#depends "openssl"
#depends "database"
#depends "postgresql"


%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end