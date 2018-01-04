require 'test_helper'
require 'file_store_with_db_backup'

describe FileStoreWithDbBackup do

  let(:store) {FileStoreWithDbBackup.new 'tmp/cache/'}
  let(:key) {'data key'}
  let(:payload) {'data value'}

  it 'caches data' do
    store.fetch(key){ payload }
    fetched = store.fetch(key) do
      fail('regenerating value')
    end
    _(fetched).must_equal payload
  end

  it 'backs up to db when asked' do
    store.write(key, payload, expires_in: 1.day, backup: true)
    backup = CacheBackup.find_by_name key
    _(backup.value).must_equal payload
    _(backup.expires).must_be_close_to 1.day.from_now, 0.01
  end

end