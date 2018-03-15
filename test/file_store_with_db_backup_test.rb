require 'test_helper'
require 'file_store_with_db_backup'

describe FileStoreWithDbBackup do

  let(:store) {FileStoreWithDbBackup.new 'tmp/cache/'}
  let(:key) {'data key'}
  let(:payload) {'data value'}

  before do
    store.clear
  end

  it 'caches data' do
    store.fetch(key){ payload }
    fetched = store.fetch(key) do
      fail('regenerating value')
    end
    _(fetched).must_equal payload
  end

  it 'backs up to db when asked' do
    store.fetch(key, expires_in: 1.day, backup: true) { payload }
    backup = CacheBackup.find_by_name key
    _(backup.value).must_equal payload
    _(backup.expires).must_be_close_to 1.day.from_now, 0.05
  end

  it 'deletes from the db' do
    store.write(key, payload, backup: true)
    store.delete(key)
    _(CacheBackup).wont_be :exists?, {name: key}
  end

  it 'reloads db entries into the cache' do
    CacheBackup.create(name: 'reload test', value: 'test')
    fresh_store = FileStoreWithDbBackup.new 'tmp/cache/'
    _(fresh_store.fetch('reload test')).must_equal 'test'
  end

  test 'old db entries are not reloaded into the cache' do
    key = 'expired entry test'
    CacheBackup.create(name: key, value: 'test', expires: 1.minute.ago)
    fresh_store = FileStoreWithDbBackup.new 'tmp/cache/'
    _(fresh_store.fetch(key)).must_be_nil
  end

  test 'future db entries are reloaded into the cache' do
    key = 'current entry test'
    CacheBackup.create(name: key, value: 'test', expires: 1.minute.from_now)
    fresh_store = FileStoreWithDbBackup.new 'tmp/cache/'
    _(fresh_store.fetch(key)).must_equal 'test'
  end

end