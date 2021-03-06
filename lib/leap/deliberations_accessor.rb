module Leap
  # Provides an intelligent accessor method for a subject instance's deliberations.
  # @see Leap::Subject
  module DeliberationsAccessor
    # Returns a special hash of deliberations that will make necessary decisions if they have not yet been made.
    def deliberations
      @deliberations ||= Hash.new do |h, k|
        return nil unless respond_to? k
        send k
        h[k]
      end
    end
  end
end
