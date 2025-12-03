class AddColumnToJournals < ActiveRecord::Migration[7.1]
  def change
    add_column :journals, :transcript, :text
  end
end
