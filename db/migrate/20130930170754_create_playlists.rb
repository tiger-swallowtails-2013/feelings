class CreatePlaylists < ActiveRecord::Migration

  def up
    create_table :playlists do |t|
      t.belongs_to :user
      t.string :songs

      t.timestamp
    end
  end

  def down
      drop_table :playlists
  end
end
