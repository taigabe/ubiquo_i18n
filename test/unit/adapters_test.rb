require File.dirname(__FILE__) + "/../test_helper.rb"

class UbiquoI18n::AdaptersTest < ActiveSupport::TestCase
  
  def test_create_i18n_table
    definition = nil
    ActiveRecord::Base.silence{
      ActiveRecord::Base.connection.create_table(:test, :translatable => true, :force => true){|table| definition=table}
    }
    ActiveRecord::Base.connection.drop_table(:test)
    assert_not_nil definition[:locale]
  end
  
  def test_dont_create_i18n_table
    definition = nil
    ActiveRecord::Base.silence{
      ActiveRecord::Base.connection.create_table(:test, :force => true){|table| definition=table}
    }
    ActiveRecord::Base.connection.drop_table(:test)
    assert_nil definition[:locale]
  end

  def test_create_content_id_on_i18n_table
    definition = nil
    ActiveRecord::Base.silence{
      ActiveRecord::Base.connection.create_table(:test, :translatable => true, :force => true){|table| definition=table}
    }
    ActiveRecord::Base.connection.drop_table(:test)
    assert_not_nil definition[:content_id]
  end

  def test_change_table_with_translatable
    connection = ActiveRecord::Base.connection
    ActiveRecord::Base.silence{
      connection.create_table(:test, :force => true){}
      connection.change_table(:test, :translatable => true){}
    }
    column_names = connection.columns(:test).map(&:name).map(&:to_s)
    assert column_names.include?('content_id')
    assert column_names.include?('locale')
    assert_equal 1, connection.list_sequences("test_$").size
    connection.drop_table(:test)
  end
  
  def test_change_table_without_translatable
    connection = ActiveRecord::Base.connection
    ActiveRecord::Base.silence{
      connection.create_table(:test, :force => true){}
      connection.change_table(:test){}
    }
    column_names = connection.columns(:test).map(&:name).map(&:to_s)
    assert !column_names.include?('content_id')
    assert !column_names.include?('locale')
    assert_equal 0, connection.list_sequences("test_$").size
    connection.drop_table(:test)
  end

end
