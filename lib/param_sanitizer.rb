# Sanitizes a hash according to one of the profiles in the
# ruby Sanitize gem. 
class ParamSanitizer
  attr_accessor :input, :rule_set

  def initialize(hash, rule_set = Sanitize::Config::RESTRICTED)
    self.input = hash
    self.rule_set = rule_set
  end

  def sanitize_hash(hash)
    hash.each do |k, v|
      if v.is_a?(Hash)
        hash[k] = sanitize_hash(v)
      else
        begin
          hash[k] = sanitize_element(v)
        rescue RuntimeError => e
          raise if e.is_a?(TypeError)
          puts "#{e.message} #{hash.inspect} #{k.inspect}"
        end
      end
    end
  end

  def sanitize
    sanitize_hash(input)
  end

  protected
  def sanitize_element(element)
    return element if element.nil?

    Sanitize.clean(element, self.rule_set).strip
  end
end