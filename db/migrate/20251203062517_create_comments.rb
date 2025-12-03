class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :start_index, null: false
      t.integer :end_index, null: false
      t.references :user, null: false, foreign_key: true
      t.references :journal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
