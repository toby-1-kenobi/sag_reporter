require 'test_helper'

describe CacheBackup do

  let(:cache_backup) { CacheBackup.new name: 'test' }

  it 'must be valid' do
    _(cache_backup).must_be :valid?
  end

  it 'wont be valid with no name' do
    cache_backup.name = ''
    _(cache_backup).wont_be :valid?
  end

  it 'wont be valid with duplicate name' do
    cache_backup_dup = cache_backup.dup
    cache_backup_dup.save
    _(cache_backup).wont_be :valid?
  end

end
