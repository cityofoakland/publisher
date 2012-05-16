require 'marples/model_action_broadcast'
require 'whole_edition'

class WholeEdition
  include Marples::ModelActionBroadcast
  include Admin::BaseHelper
  include Searchable
end
