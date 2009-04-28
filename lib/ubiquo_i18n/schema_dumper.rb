module UbiquoI18n
  module SchemaDumper
    def self.included(klass)
      klass.send(:alias_method_chain, :table, :translations)
    end
    
    def table_with_translations(table, stream)
      tbl = StringIO.new
      table_without_translations(table, tbl)
      tbl.rewind
      result = tbl.read
      result.gsub!(/integer([\s]*) (\"content_id\")([^\n]*)/, ('sequence\1"'+table+'", \2'))
      stream.print result
    end
  end
end


ActiveRecord::SchemaDumper.send(:include, UbiquoI18n::SchemaDumper)
