#require 'i18n/backend/active_record'
#I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
#I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
#I18n.fallbacks.map('hi' => 'en')
