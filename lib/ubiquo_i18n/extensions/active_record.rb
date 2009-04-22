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

          if instance_methods.include?('locale=')
            # give the proper behaviour to the locale setter
            define_method('locale_with_duality=') do |locale|
              locale = case locale
              when String
                locale
              else
                locale.iso_code if locale.respond_to?(:iso_code)
              end
              send(:locale_without_duality=, locale)
            end

            alias_method_chain :locale=, :duality

          end
          
          # usage:
          # find all content in any locale: Model.locale(:ALL)
          # find spanish content: Model.locale('es')
          # find spanish or english content. If spanish and english exists, gets the spanish version. Model.locale('es', 'en')
          # find all content in spanish or any other locale if spanish dosn't exist: Model.locale('es', :ALL)
          # find all content in any locale: Model.locale(:ALL)
          #
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
          
          # usage:
          # find all items of one content: Model.content(1).first
          # find all items of some contents: Model.content(1,2,3)
          named_scope :content, lambda{|*content_ids|
            {:conditions => {:content_id => content_ids}}
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
              self.content_id = self.class.connection.next_val_sequence("#{self.class.table_name}_content_id")
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
