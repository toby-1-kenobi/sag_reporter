class FileStoreWithDbBackup < ActiveSupport::Cache::FileStore

  def initialize(*args)
    super *args
    begin
      load_from_backup
    rescue ActiveRecord::ConnectionNotEstablished => e
      puts("Tried to load cache entries from database but #{e.message}")
    end
  end

  def write(name, value, options = nil)
    super(name, value, options)
    if options and options[:backup]
      backup = CacheBackup.find_or_create_by(name: name)
      backup.value = YAML::dump(value)
      if options[:expires_in]
        backup.expires = options[:expires_in].from_now
      end
      backup.save
    end
  end

  def delete(name)
    super(name)
    CacheBackup.where(name: name).destroy_all
  end

  # look for entries in the db and load them into the cache
  # also clean up expired entries from the db
  def load_from_backup
    now = Time.now
    CacheBackup.where('expires > ? OR expires IS NULL', now).find_each do |entry|
      if entry.name and entry.value
        begin
          if entry.expires.present?
            expires_in_seconds = entry.expires - now
            write(entry.name, YAML::load(entry.value), expires_in: expires_in_seconds.seconds)
          else
            write(entry.name, YAML::load(entry.value))
          end
        rescue ArgumentError => e
          Rails.logger.error "Failed to load cached value from database"
          Rails.logger.error "Row ID: #{entry.id}, error: #{e.message}"
        end
      end
    end
    CacheBackup.where('expires <= ?', now).destroy_all
  end

end