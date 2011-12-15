class UberEdition
  include Mongoid::Document
  
  field :title, :type => String
  field :created_at, :type => DateTime, :default => lambda { Time.now }
  field :overview, :type => String
  field :alternative_title, :type => String
  field :state, :type => String
  field :kind, :type => String
  field :need_id, :type => Integer
  field :extras, :type => Hash
  field :number, :type => Integer, :default => 1
  field :slug, :type => String
  
  embeds_many :actions
  embeds_many :uber_parts
  
  accepts_nested_attributes_for :uber_parts, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs['body'].blank? }

  # TODO: Revisit workflow handling
  include Workflow
  include PublicationStates

  def self.build_clone(user, kind = nil)
    new_edition = self.dup
    new_edition.created_at = Time.now
    new_edition.actions = []
    new_edition.actions << Action.new(:request_type => NEW_VERSION, :requester => user)
    new_edition.kind = kind unless kind.nil?
    new_edition.number +=1
    new_edition
  end

  def progress(activity_details, current_user)
    activity = activity_details.delete(:request_type)

    if ['request_review','approve_review','approve_fact_check','request_amendments','send_fact_check','receive_fact_check','publish','archive','new_version'].include?(activity)
      result = current_user.send(activity, self, activity_details)
    elsif activity == 'start_work'
      result = current_user.start_work(self)
    else
      raise "Unknown progress activity: #{activity}"
    end

    if result
      save!
    else
      result
    end
  end

  def self.find_and_identify_edition(slug, number = nil)
    if number.present? and number == 'latest'
      where(slug: slug).order('number').last
    elsif number.present?
      where(slug: slug, number: number).first
    else
      where(slug: slug, state: 'published').first
    end
  end
end
