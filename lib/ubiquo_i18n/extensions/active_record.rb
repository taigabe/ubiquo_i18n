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
          
          
          named_scope :locale, lambda{|*locales|
            locales = [Locale.current] if locales.size == 0
            all_locales = locales.delete(:ALL)
            locales_string = locales.size > 0 ? (["locale != ?"]*(locales.size)).join(", ") : nil
            {
              :conditions => ["#{self.table_name}.id in (" +
                "SELECT distinct on (content_id) id " + 
                "FROM #{self.table_name} " +
                (all_locales ? "" : "WHERE #{self.table_name}.locale in (?)") +
                "ORDER BY #{ ["content_id", locales_string].compact.join(", ")})", *[(all_locales ? nil : locales), *locales].compact]
            }
          }
        end
      end
      
      module InstanceMethods
        
        def self.included(klass)
          klass.alias_method_chain :create, :i18n_content_id
          klass.alias_method_chain :create, :locale
        
        end
        
        # proxy to add a new content_id if empty on creation
        def create_with_i18n_content_id
          if self.class.instance_variable_get('@translatable_attributes')
            # we do this even if there is not currently any tr. attribute, 
            # as long as @translatable_attributes is defined
            unless self.content_id
              self.content_id = self.class.connection.next_val_sequence("#{self.class.to_s.tableize}_content_id")
            end
          end
          create_without_i18n_content_id
        end

        # proxy to add a new content_id if empty on creation
        def create_with_locale
          if self.class.instance_variable_get('@translatable_attributes')
            # we do this even if there is not currently any tr. attribute, 
            # as long as @translatable_attributes is defined
            unless self.locale
              self.locale = Locale.current
            end
          end
          create_without_locale
        end
        
      end

    end
  end
end
