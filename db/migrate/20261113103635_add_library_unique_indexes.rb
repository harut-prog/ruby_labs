class AddLibraryUniqueIndexes < ActiveRecord::Migration[7.1]

  def change
  add_index :books, :isbn, unique: true
  add_index :members, :email, unique: true
  end
end
