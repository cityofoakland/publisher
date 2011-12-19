module Admin::BaseHelper

  def resource_edit_view
    "/admin/#{@latest_edition.container.class.to_s.underscore.downcase.pluralize}/edit"
  end
  
  def skip_fact_check_for_edition(edition)
    send("skip_fact_check_admin_#{edition.container.class.to_s.underscore}_edition_path", edition.container, edition)
  end

  def edition_can_be_deleted?(edition)
    edition.container.editions.size > 1 and ! edition.is_published? 
  end

  def produce_fact_check_request_text
    @edition = @latest_edition
    render :partial => '/noisy_workflow/request_fact_check'
  end

  def friendly_date(date)
    if Time.now - date < 2.days
      time_ago_in_words(date) + " ago."
    else
      date.strftime("%d/%m/%Y %R")
    end
  end

  include Admin::PathsHelper
  include Admin::ProgressFormsHelper
end
