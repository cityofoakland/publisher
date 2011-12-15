namespace :uber do
  task :migrate => :environment do
    class EditionTranslator
      attr_accessor :original_edition, :uber_edition
      
      @extra_fields = [:minutes_to_complete, :uses_government_gateway, :expectation_ids, 
        :introduction, :more_information, :video_url, :video_summary, :place_type, :will_continue_on, 
        :link, :alternate_methods]
      
      def initialize(original_edition)
        self.original_edition = original_edition
      end
      
      def build_uber_edition
        self.uber_original_edition = UberEdition.new(
          title: original_edition.title,
          overview: original_edition.overview,
          alternative_title: original_edition.alternative_title,
          state: original_edition.state,
          kind: publication.class.to_s,
          number: original_edition.version_number,
          slug: original_edition.container.slug
          # need_id: publication.metadata.need_id
        )
      end
      
      def assign_single_part
        new_part = uber_edition.uber_parts.build(extras: {})
        new_part.body = original_edition.body if original_edition.respond_to?(:body)

        self.class.extra_fields.each do |key|
          if original_edition.respond_to?(key) and original_edition.send(key).present?
            new_part.extras[key] = original_edition.send(key) 
          end
        end
      end

      def assign_parts
        original_edition.parts.each do |part|
          uber_edition.uber_parts.build(order: part.order, title: part.title, body: part.body, slug: part.slug)
        end
      end
      
      def run
        build_uber_edition
        if original_edition.respond_to?(:parts)
          assign_parts
        else
          assign_single_part
        end
        uber_edition
      end
    end

    # TODO: Local transactions
    # TODO: Get need_id
    # TODO: Maybe begin to move towards tags?
    UberEdition.delete_all
    Publication.all.each do |publication|
      publication.editions.each do |edition|
        uber_edition = EditionTranslator.new(edition).run
        uber_edition.save!
      end
    end
  end
end