class SagReporter::Application
  APP_SHORT_NAME = 'Rev79'
  VERSION = '3.2.8'
  NATION = ENV['REV79_VARIETY'].downcase == 'sandbox' ? 'Middle Earth' : 'India'
end