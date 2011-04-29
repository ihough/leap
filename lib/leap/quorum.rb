module Leap
  # A basic building block of a Leap decision.
  #
  # A quorum encapsulates a specific methodology for drawing a conclusion based on a set of input information.
  class Quorum
    include XmlSerializer

    # The name of the quorum
    attr_reader :name
    
    # Quorum attribute requirements, as defined by the <tt>:needs</tt> option
    attr_reader :requirements
    
    # Useful attributes, as defined by the <tt>:wants</tt> option
    attr_reader :supplements
    
    # The quorum's methodology, as a Ruby closure.
    attr_reader :process
    
    # Protocols with which this quorum complies.
    attr_reader :compliance
    
    # (see Leap::Committee#quorum)
    def initialize(name, options, blk)
      @name = name
      @requirements = Array.wrap options[:needs]
      @supplements = Array.wrap options[:appreciates]
      @compliance = Array.wrap options[:complies]
      @process = blk
    end
    
    # Do the provided characteristics satisfy the quorum's requirements?
    # @param [Hash] characteristics
    # @return [TrueClass, NilClass]
    def satisfied_by?(characteristics)
      (requirements - characteristics.keys).empty?
    end
    
    # Does the quorum comply with the given set of protocols?
    # @param [Array] guideines The list of protocols we're for which we're checking compliance.
    # @return [TrueClass, NilClass]
    def complies_with?(guidelines)
      (guidelines - compliance).empty?
    end
    
    # Perform the quorum's methodology using the given characteristics.
    # @param [Hash] characteristics
    # @return The methodology's result
    def acknowledge(characteristics, considerations)
      considerations.unshift characteristics
      process.call(*considerations[0...process.arity])
    end
    
    # All characteristics either needed or wanted by the quorum.
    def characteristics
      requirements + supplements
    end

    def as_json(*)
      { 
        'name' => name.to_s,
        'requirements' => requirements.map(&:to_s),
        'appreciates' => supplements.map(&:to_s),
        'complies' => compliance.map(&:to_s)
      }
    end

    def to_xml(options = {})
      super options do |xml|
        xml.quorum do |quorum_block|
          quorum_block.name name.to_s, :type => 'string'
          array_to_xml(quorum_block, :requirements, requirements)
          array_to_xml(quorum_block, :appreciates, supplements, 'supplement')
          array_to_xml(quorum_block, :complies, compliance, 'compliance')
        end
      end
    end
  end
end
