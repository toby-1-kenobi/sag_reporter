class JoshuaProject
  include HTTParty

  base_uri 'joshuaproject.net/api/v2'
  format :json
  default_params api_key: Rails.application.secrets.joshua_project_api_key

  @success_message = 'Success!'

  def self.language(iso)
    get '/languages', query: {'ROL3' => iso}
  end

  def self.success? (response)
    response['status']['message'] == @success_message
  end

end