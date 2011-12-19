class Admin::EditionsController < Admin::BaseController
  polymorphic_belongs_to :guide, :answer, :transaction, :local_transaction, :place, :programme
  actions :create, :update, :destroy

  def create
    new_edition = current_user.new_version(edition_parent.latest_edition)
    assigned_to_id = (params[:edition] || {}).delete(:assigned_to_id)
    if new_edition and new_edition.save
      update_assignment new_edition, assigned_to_id
      redirect_to params[:return_to] and return if params[:return_to]
      redirect_to [:admin, edition_parent], :notice => 'New edition created'
    else
      alert = 'Failed to create new edition'
      alert += new_edition ? ": #{new_edition.errors.inspect}" : ": couldn't initialise"
      redirect_to [:admin, edition_parent], :alert => alert
    end
  end

  def update
    assigned_to_id = (params[:edition] || {}).delete(:assigned_to_id)
    update! do |success, failure|
      success.html {
        update_assignment resource, assigned_to_id
        redirect_to params[:return_to] and return if params[:return_to]
        redirect_to [:admin, parent]
      }
      failure.html {
        prepend_view_path "app/views/admin/publication_subclasses"
        prepend_view_path admin_template_folder_for(parent)

        instance_variable_set("@#{parent.class.to_s.downcase}".to_sym, parent)
        @resource = parent
        @latest_edition = parent.latest_edition
        flash.now[:alert] = "We had some problems saving. Please check the form below."

        render :template => "show"

      }
      success.json {
        update_assignment resource, assigned_to_id
        render :json => resource
      }
      failure.json { render :json => resource.errors, :status=>406 }
    end
  end

  def start_work
    if resource.progress({request_type: 'start_work'}, current_user)
      redirect_to [:admin, edition_parent], :notice => "Work started on #{edition_parent.class.to_s.underscore.humanize}"
    else
      redirect_to [:admin, edition_parent], :alert => "Couldn't start work on #{edition_parent.class.to_s.underscore.humanize.downcase}"
    end
  end

  def progress
    if resource.progress(params[:activity].dup, current_user)
      redirect_to [:admin, edition_parent], :notice => "#{edition_parent.class.to_s.underscore.humanize} updated"
    else
      redirect_to [:admin, edition_parent], :alert => "Couldn't #{params[:activity][:request_type].to_s.humanize.downcase} for #{edition_parent.class.to_s.underscore.humanize.downcase}"
    end
  end

  def skip_fact_check
    if resource.progress({request_type: 'receive_fact_check', comment: "Fact check skipped by request."}, current_user)
      redirect_to [:admin, edition_parent], :notice => "The fact check has been skipped for this publication."
    else
      redirect_to [:admin, edition_parent], :alert => "Could not skip fact check for this publication."
    end
  end

  protected
    def update_assignment(edition, assigned_to_id)
      return if assigned_to_id.blank?
      assigned_to = User.find(assigned_to_id)
      return if edition.assigned_to == assigned_to
      current_user.assign(edition, assigned_to)
    end

    # I think we can get this via InheritedResources' "parent" method, but that wasn't
    # working for our create method and I can't see where it's initialised
    def edition_parent
      @edition_parent ||=
        if params[:answer_id]
          Answer.find(params[:answer_id])
        elsif params[:guide_id]
          Guide.find(params[:guide_id])
        elsif params[:transaction_id]
          Transaction.find(params[:transaction_id])
        elsif params[:programme_id]
          Programme.find(params[:programme_id])
        elsif params[:local_transaction_id]
          LocalTransaction.find(params[:local_transaction_id])
        elsif params[:place_id]
          Place.find(params[:place_id])
        end
      @edition_parent
    end
end
