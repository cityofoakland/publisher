class UberPart
  include Mongoid::Document

  embedded_in :uber_edition

  field :order, :type => Integer
  field :title, :type => String
  field :body, :type => String
  field :slug, :type => String
  field :created_at, :type => DateTime, :default => lambda { Time.now }

  validates_exclusion_of :slug, :in => %W(video), :message => "Can not be video"
  validates :title, :presence => true, :if => proc { |up| up.uber_edition.uber_parts.length > 1 }
  validates :slug, :presence => true, :if => proc { |up| up.uber_edition.uber_parts.length > 1 }
end
