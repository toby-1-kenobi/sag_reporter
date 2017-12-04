module ParamsHelper
  extend ActiveSupport::Concern

  private

  # Recursively search through a set of parameters finding hashes attached to
  # certain keys. If one of these hashes is found swap it with its array of keys
  # this is needed because it's hard with strong parameters to permit something like
  # :languages => {"108" => "108", "42" => "42"}
  # especially when it is buried deep in the hash
  def param_reduce(params, special_keys)
    params.each do |key, value|
      if special_keys.include? key and value.respond_to? 'keys'
        params[key] = value.keys
      elsif value.kind_of? Hash
        param_reduce(params[key], special_keys)
      end
    end
  end

end