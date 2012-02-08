require 'csv'

class LocalServiceUrl
  include Mongoid::Document

  LGIL_CODE_PROVIDING_INFORMATION = 8
  
  field :lgsl_code, type: String
  field :lgil_code, type: String
  field :url, type: String

  embedded_in :local_authority
  
  validates_presence_of :url, :lgil_code, :lgsl_code
end
