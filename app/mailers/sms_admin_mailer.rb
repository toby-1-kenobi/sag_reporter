class SmsAdminMailer < ApplicationMailer

  def sms_server_fail(msg)
    @msg = msg
    mail(to: Rails.application.secrets.sms_admin_email, subject: "#{SagReporter::Application::APP_SHORT_NAME} SMS server fail")
  end

end
