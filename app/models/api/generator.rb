require 'active_support/inflector'
require 'builder'

module Api
  module Generator
    def self.generator_class(edition)
      "Api::Generator::#{edition.container.class.to_s}".constantize
    end

    def self.edition_to_hash(edition, *args)
      generator = generator_class(edition)
      publication_fields =  [:audiences, :slug, :tags, :updated_at, :section, :related_items]
      edition_fields     =  [:title, :alternative_title, :overview] + generator.extra_fields

      attrs = edition.container.as_json(:only => publication_fields)
      attrs.merge!(edition.as_json(:only => edition_fields))
      
      if edition.respond_to?(:parts)
         attrs['parts'] = edition.parts.sort_by(&:order).collect { |p| p.as_json(:only => [:slug, :title, :body]) }
      end
      
      if edition.respond_to?(:expectations)
        attrs['expectations'] = edition.expectations.map {|e| e.as_json(:only => [:css_class,:text]) }        
      end

      attrs['type'] = edition.container.class.to_s.underscore
      generator.edition_to_hash(attrs,edition,*args)
    end

    module RelatedItems
      def self.for publication
        related_items = StringIO.new
        html = Builder::XmlMarkup.new :target => related_items
        publication.related_items.each do |slug|
          related_item = RelatedItem.find slug
          next unless related_item.present?
          next unless related_item.published?
          html.li class: related_item.format do |item|
            item.a href: related_item.path do |a|
              a.text! related_item.name
            end
          end
        end
        related_items.rewind
        related_items.string
      end
    end

    module Guide
      def self.edition_to_hash(edition,options={})
        attrs = edition.guide.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs.merge!(edition.as_json(:only => [:title, :alternative_title, :overview]))
        attrs['related_items'] = RelatedItems.for edition.guide
        attrs['parts'] = edition.parts.sort_by(&:order).collect { |p| p.as_json(:only => [:slug, :title, :body]).merge('number' => p.order) }
        attrs['type'] = 'guide'
        attrs
      end
    end

    module Answer
      def self.edition_to_hash(edition,options={})
        attrs = edition.answer.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs['type'] = 'answer'
        attrs['related_items'] = RelatedItems.for edition.answer
        attrs.merge!(edition.as_json(:only => [:title,:body, :alternative_title, :overview]))
      end
    end
    
    module Transaction
      def self.edition_to_hash(edition,options={})
        attrs = edition.transaction.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs['related_items'] = RelatedItems.for edition.transaction
        attrs['type'] = 'transaction'
        attrs['expectations'] = edition.expectations.map {|e| e.as_json(:only => [:css_class,:text]) }
        attrs.merge!(edition.as_json(:only => [:title, :introduction, :more_information, :will_continue_on,:link, :alternative_title, :overview, :minutes_to_complete, :uses_government_gateway]))
      end
    end

    class LocalTransaction < Base
      def self.extra_fields
        [ :introduction, 
          :more_information, 
          :minutes_to_complete]
      end

      def self.authority_to_json(la)
        la.as_json(:only => [:snac, :name], :include => {:lgils => {:only => [:url, :code]}})
      end

      def self.edition_to_hash(attrs,edition,options = {})
        snac = options[:snac]
        all  = options[:all]
        attrs = edition.local_transaction.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs.merge!(edition.as_json(:only => [:title, :introduction, :more_information, :alternative_title, :overview, :minutes_to_complete]))
        attrs['related_items'] = RelatedItems.for edition.local_transaction
        attrs['type'] = 'local_transaction'
        attrs['expectations'] = edition.expectations.map { |e| e.as_json(:only => [:css_class, :text]) }
        if snac
          attrs['authority'] = edition.local_transaction.lgsl.authorities.where(snac: snac).first.as_json(:only => [:snac, :name], :include => {:lgils => {:only => [:url, :code]}})
        elsif all
          attrs['authorities'] = edition.local_transaction.lgsl.authorities.all.as_json(:only => [:snac, :name], :include => {:lgils => {:only => [:url, :code]}})
        end
        attrs
      end
    end

    module Place
      def self.edition_to_hash(edition, options={})
        attrs = edition.place.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs.merge!(edition.as_json(:only => [:title, :introduction, :more_information, :place_type, :alternative_title, :overview]))
        attrs['related_items'] = RelatedItems.for edition.place
        attrs['expectations'] = edition.expectations.map {|e| e.as_json(:only => [:css_class,:text]) }
        attrs['type'] = 'place'
        attrs
      end

    end
    
    module Programme
      def self.edition_to_hash(edition,options={})
        attrs = edition.programme.as_json(:only => [:audiences, :slug, :tags, :updated_at, :section])
        attrs.merge!(edition.as_json(:only => [:title, :alternative_title, :overview]))
        attrs['related_items'] = RelatedItems.for edition.programme
        attrs['parts'] = edition.parts.sort_by(&:order).collect { |p| p.as_json(:only => [:slug, :title, :body]).merge('number' => p.order) }
        attrs['type'] = 'programme'
        attrs
      end
    end
  end
end
