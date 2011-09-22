class PublicationMetadata
  module HTMLGenerator
    def html
      buffer = StringIO.new
      builder = Builder::XmlMarkup.new :target => buffer
      yield builder
      buffer.rewind
      buffer.string.html_safe
    end
    private :html
  end

  class AudienceList
    include HTMLGenerator
    initialize_with :audiences

    def to_html
      html do |html|
        html.text! audiences.map { |a| a['name'] }.sort.join ', '
      end
    end
  end

  class RelatedItemList
    include HTMLGenerator
    initialize_with :related_items

    def to_html
      html do |html|
        html.text! related_items.map { |i| i['artefact']['name'] }.sort.join ', '
      end
    end
  end

  include HTMLGenerator

  initialize_with :publication

  def to_html
    html do |metadata|
      attributes.each_pair do |name, value|
        metadata.dt(:class => name) { |term| term.text! name.humanize }
        presenter_name = name.classify
        presenter_name += 'List' if value.kind_of? Array
        if self.class.const_defined? presenter_name
          presenter = self.class.const_get presenter_name
          instance = presenter.new value
          value = instance.to_html
        end
        metadata.dd(:class => name) { |definition| definition.text! value.to_s }
      end
    end
  end

  def attributes
    data = JSON.parse open(uri).read
    data.except('updated_at', 'created_at', 'id', 'owning_app', 'kind', 'active')
  end
  private :attributes

  def uri
    publication.panopticon_uri + '.js'
  end
  private :uri
end
