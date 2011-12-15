class EditionsController < ApplicationController
  def show
    edition = UberEdition.find_and_identify_edition(params[:id], params[:edition])
    head 404 and return if edition.nil?
    render :json => edition
  end
end
