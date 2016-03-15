if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'Google',
      :google_access_key_id     => ENV['GOOGLE_ACCESS_KEY'],
      :google_secret_access_key => ENV['GOOGLE_SECRET_KEY']
    }
    config.fog_directory     =  ENV['GOOGLE_BUCKET']
  end
end