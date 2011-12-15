module PublicationStates
  def self.included(klass)
    klass.state_machine :initial => :lined_up do
      after_transition :on => :request_amendments do |edition, transition|
        edition.container.mark_as_rejected
      end 
      after_transition :on => :approve_review do |edition, transition|
        edition.container.mark_as_accepted
      end 
      before_transition :on => :publish do |edition, transition|
        edition.container.editions.where(state: 'published').all.each{|e| e.archive }    
      end                                                                                
      after_transition :on => :publish do |edition, transition|
        edition.container.update_in_search_index
      end

      event :start_work do
        transition :lined_up => :draft
      end

      event :request_review do
        transition [:draft, :amends_needed] => :in_review
      end

      event :approve_review do
        transition :in_review => :ready
      end

      event :approve_fact_check do
        transition :fact_check_received => :ready
      end

      event :request_amendments do
        transition [:fact_check_received, :in_review] => :amends_needed
      end

      event :send_fact_check do
        transition :ready => :fact_check
      end

      event :receive_fact_check do
        transition :fact_check => :fact_check_received
      end

      event :publish do
        # allow draft to be published as emergency, but do not expose in UI for now
        transition [:draft, :ready] => :published
      end

      event :archive do
        transition :published => :archived
      end

    end
  end
end