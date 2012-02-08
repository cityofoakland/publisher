class LocalTransaction < Publication
  embeds_many   :editions,  class_name: 'LocalTransactionEdition', inverse_of: :local_transaction

  field         :lgsl_code, type: String

  validates_presence_of :lgsl_code

  def self.edition_class
    LocalTransactionEdition
  end

  def search_format
    "transaction"
  end
  
  def service
    LocalService.where(lgsl_code: lgsl_code).first
  end

  def service_provided_by?(snac)
    authority = LocalAuthority.where(snac: snac).first
    authority && authority.local_service_urls.where(lgsl_code: lgsl_code).any?
  end
end
