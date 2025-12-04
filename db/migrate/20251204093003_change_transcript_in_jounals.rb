class ChangeTranscriptInJounals < ActiveRecord::Migration[7.1]
  def change
    change_column :journals, :transcript, :jsonb, using: "transcript::text::jsonb"
  end
end
