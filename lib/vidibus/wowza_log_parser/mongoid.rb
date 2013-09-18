module Vidibus
  module WowzaLogParser
    module Mongoid
      extend ActiveSupport::Concern

      # Things that should added when including this module into the class.
      included do
        field :name, :type => String
        validates :name, :presence => true
      end

      # Class methods go here.
      module ClassMethods
        def species
          'human'
        end
      end

      # Instance methods go here.
      def shout
        'Yay!'
      end
    end
  end
end
