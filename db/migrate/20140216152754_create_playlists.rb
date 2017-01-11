class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :name
      t.boolean :is_download

      t.timestamps
    end
  end
end
