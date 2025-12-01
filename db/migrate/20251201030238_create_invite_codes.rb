class CreateInviteCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :invite_codes do |t|
      t.string :code
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at
      t.boolean :used

      t.timestamps
    end
  end
end
