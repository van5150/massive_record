module MassiveRecord
  module ORM
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods
        def create(attributes = {})
          new(attributes).tap do |record|
            record.save
          end
        end
      end


      def new_record?
        @new_record
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def destroyed?
        @destroyed
      end



      
      def save(*)
        create_or_update
      end

      def save!(*)
        create_or_update or raise RecordNotSaved
      end

      def touch
        true
      end

      def destroy
        @destroyed = true
        true
      end

      def delete
        @destroyed = true
        true
      end


      private


      def create_or_update
        !!(new_record? ? create : update)
      end

      def create
        @new_record = false
        true
      end

      def update
        true
      end



      #
      # Returns a hash with fields
      # 
      # TODO  This one should read from the field definition
      #       and return a populated hash with correct
      #       keys for attributes and maybe give it's default value?
      #       Right now it simply returns a hash as we have no
      #       real concept of our fields.
      #
      def attributes_from_field_definition
        Hash.new
      end
    end
  end
end