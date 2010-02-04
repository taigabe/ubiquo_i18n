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
  
end
