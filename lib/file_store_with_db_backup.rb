class FileStoreWithDbBackup < ActiveSupport::Cache::FileStore

  def write(name, value, options = nil)
    super(name, value, options)
    Rails.logger.debug('write!')
    if options[:backup]
      backup = CacheBackup.find_or_create_by(name: name)
      backup.value = value
      if options[:expires_in]
        backup.expires = options[:expires_in].from_now
      end
      backup.save
    end
  end

end