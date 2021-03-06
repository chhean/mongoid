# encoding: utf-8
module Mongoid #:nodoc:
  module Associations #:nodoc:
    class Options #:nodoc:

      # Create the new +Options+ object, which provides convenience methods for
      # accessing values out of an options +Hash+.
      def initialize(attributes = {})
        @attributes = attributes
      end

      # Returns the extension if it exists, nil if not.
      def extension
        @attributes[:extend]
      end

      # Returns true is the options have extensions.
      def extension?
        !extension.nil?
      end

      # Return the foreign key based off the association name.
      def foreign_key
        if as
          key = as.to_s.foreign_key
        else
          key = @attributes[:foreign_key] || klass.name.to_s.foreign_key
          key.to_s
        end
        
        key
      end
      
      def foreign_type
        name+"_type"
      end

      # Returns the name of the inverse_of association
      def inverse_of
        @attributes[:inverse_of]
      end
      
      def as
        @attributes[:as]
      end

      # Return a +Class+ for the options. See #class_name
      def klass
        class_name.constantize
      end
      
      # Returns the class name from the options
      def class_name
        class_name = (@attributes[:class_name] ? @attributes[:class_name].to_s : name.to_s).classify
      end

      # Returns the association name of the options.
      def name
        @attributes[:name].to_s
      end

      # Returns whether or not this association is polymorphic.
      def polymorphic
        @attributes[:polymorphic] == true
      end

      # Used with references_many to save as array of ids.
      def stored_as
        @attributes[:stored_as]
      end
    end
  end
end
