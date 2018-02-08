# load database backup of cache into the cache

Rails.cache.load_from_backup unless Rails.env.test?