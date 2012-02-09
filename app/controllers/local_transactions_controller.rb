require 'api/generator'

class LocalTransactionsController < ApplicationController
  respond_to :json

  def verify_snac
    publication = Publication.where(slug: params[:id]).first
    head 404 and return if publication.nil?
    
    matching_code = params[:snac_codes].detect { |snac| publication.service_provided_by?(snac) }

    if matching_code
      render :json => { snac: matching_code }
    else
      render :text => '', :status => 422
    end
  end

end
