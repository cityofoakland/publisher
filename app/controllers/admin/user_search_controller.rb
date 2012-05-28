class Admin::UserSearchController < Admin::BaseController
  respond_to :html

  def index
    @user_filter = params[:user_filter] || current_user.uid
    user = params[:user_filter] ? User.find_by_uid(@user_filter) : current_user

    # Including recipient_id on actions will include anything that has been
    # assigned to the user we're looking at, but include the check anyway to
    # account for manual assignments
    editions = WholeEdition.any_of(
      {'assigned_to_id' => user.id},
      {'actions.requester_id' => user.id},
      {'actions.recipient_id' => user.id}
    ).excludes(state: 'archived').order_by(last_updated_at: -1)

    # Need separate assignments here because Kaminari won't preserve pagination
    # info across a map, and we don't want to load every edition and paginate
    # the resulting array
    @page_info = editions.page(params[:page]).per(20)
    @editions = @page_info.map { |e| UserSearchEditionDecorator.new e, user }
  end
end
