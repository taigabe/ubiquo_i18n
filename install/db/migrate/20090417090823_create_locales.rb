class CreateLocales < ActiveRecord::Migration
  def self.up
    create_table :locales do |t|
      t.string :iso_code
    end
  end

  def self.down
    drop_table :locales
  end
end
