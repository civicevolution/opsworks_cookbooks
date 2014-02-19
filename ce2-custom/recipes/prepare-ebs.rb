log "^^^^^^ Feb 18 10:55 custom recipe ce2-custom::prepare-db-ebs"

node[:deploy].each do |application, deploy|

  log "^^^^^^ Do prepare-db-ebs Feb 18 10:55 application: #{application}, deploy[:application_type]: #{deploy[:application_type]}"

  if deploy[:application_type] != 'rails'
    log("Skipping ce2-custom::prepare-db-ebs for application #{application} as it is not a Rails app")
    next
  end

  # determine the device for /data which was added by opsworks

  df_results = `df -T | grep \/data`
  if df_results && df_results.match(/\/data$/)
    device = df_results.match(/^[^\s]*/)[0]
  end
  # => "/dev/xvdi"
  if device
    execute "mkfs_#{device}" do
      command "mkfs -t ext4 #{device}"
      not_if do
        BlockDevice::wait_for(device)
        # check volume filesystem
        system("blkid -s TYPE -o value #{device}") == 'ext4'
      end
    end
  end


end