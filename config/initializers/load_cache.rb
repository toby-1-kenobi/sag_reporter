# load database backup of cache into the cache

Rails.cache.load_from_backup if Rails.env.production? and Rails.cache.respond_to? :load_from_backup