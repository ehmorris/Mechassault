class CreateScrapers < ActiveRecord::Migration
  def change
    create_table :scrapers do |t|

      t.timestamps
    end
  end
end
