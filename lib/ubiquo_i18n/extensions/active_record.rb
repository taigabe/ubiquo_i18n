module UbiquoI18n
  module Extensions
    module ActiveRecord

      def self.append_features(base)
        super
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end

      module ClassMethods

        # Class method for ActiveRecord that states which attributes are translatable and therefore when updated will be only updated for the current locale.
        #
        # EXAMPLE:
        #
        #   translatable :title, :description

        def translatable(*attrs)
          # inherit translatable attributes
          @translatable_attributes = self.superclass.instance_variable_get('@translatable_attributes') || []
          # add attrs from this class
          @translatable_attributes += attrs

          # add locale relation
          #          self.belongs_to(:locale, {
          #                          :foreign_key => :locale,
          #                          :class_name => "::Locale"
          #                        }) unless self.reflections[:locale]

          if instance_methods.include?('locale=')
            # give the proper behaviour to the locale setter
            alias_method :set_locale, :locale=

            define_method('locale=') do |locale|
              locale = case locale
              when String
                locale
              else
                locale.iso_code if locale.respond_to?(:iso_code)
              end
              set_locale locale
            end
          end
        end
      end
      
      module InstanceMethods
        
        def self.included(klass)
          #require 'ruby-debug';debugger
          klass.alias_method_chain :create, :content_id
        
        end
        
        # proxy to add a new content_id if empty on creation
        def create_with_content_id
          if self.class.instance_variable_get('@translatable_attributes')
            # we do this even if there is not currently any tr. attribute, 
            # as long as @translatable_attributes is defined
            unless self.content_id
              self.content_id = self.class.connection.next_val_sequence("#{self.class.to_s}_content_id")
            end
          end
          create_without_content_id
        end
      end


    end
  end
end
