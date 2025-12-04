class AddTranscriptIndexToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :transcript_index, :integer
  end
end
