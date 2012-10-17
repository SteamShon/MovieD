class AddOriginalIdToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :original_id, :string
  end
end
