module MassiveRecord
  module ORM
    module Schema
      module TableInterface
        extend ActiveSupport::Concern

        included do
          class_attribute :column_families, :instance_writer => false
          self.column_families = nil
        end


        module ClassMethods
          #
          # DSL method exposed into class. Makes it possible to do:
          #
          # class Person < MassiveRecord::ORM::Table
          #   column_family :info do
          #     field :name
          #     field :age, :integer, :default => 0
          #     field :points, :integer, :column => :number_of_points
          #   end
          # end
          #
          #
          def column_family(name, &block)
            ensure_column_families_exists
            column_families.family_by_name_or_new(name).instance_eval(&block)
          end

          #
          # If you need to add fields to a column family dynamically, use this method.
          # It wraps functionality needed to keep the class in a consistent state.
          # There is also an instance method defined which will inject default value
          # to the object itself after defining the field.
          #
          def add_field_to_column_family(family_name, *field_args)
            ensure_column_families_exists

            field = Field.new_with_arguments_from_dsl(*field_args)
            column_families.family_by_name_or_new(family_name) << field

            undefine_attribute_methods if respond_to? :undefine_attribute_methods

            field
          end

          #
          # Create column families and fields with incomming array of column names.
          # It should be on a unique and complete form like ["info:name", "info:phone"]
          #
          def autoload_column_families_and_fields_with(column_names)
            column_names.each do |column_family_and_column_name|
              family_name, column_name = column_family_and_column_name.split(":")
              
              if family = column_families.family_by_name(family_name) and family.autoload_fields?
                family.add? Field.new(:name => column_name)
              end
            end
          end

          #
          # Returns an array of known attributes based on all fields found
          # in all column families.
          #
          def known_attribute_names
            column_families.present? ? column_families.attribute_names : []
          end

          #
          # Returns a hash where attribute names are keys and it's field
          # is the value.
          #
          def attributes_schema
            column_families.present? ? column_families.to_hash : {}
          end

          #
          # Returns a hash with attribute name as keys, default values read from field as value.
          #
          def default_attributes_from_schema
            attributes_schema.inject({}) do |hash, (attribute_name, field)|
              hash[attribute_name] = field.default
              hash
            end
          end


          private
          def ensure_column_families_exists
            self.column_families = ColumnFamilies.new if column_families.nil?
          end
        end


        def attributes_schema
          self.class.attributes_schema
        end

        
        #
        # Same as defined in class method, but also sets the default value
        # in current object it was called from.
        #
        def add_field_to_column_family(*args)
          new_field = self.class.add_field_to_column_family(*args)
          method = "#{new_field.name}="
          send(method, new_field.default) if respond_to? method
        end
      end
    end
  end
end
