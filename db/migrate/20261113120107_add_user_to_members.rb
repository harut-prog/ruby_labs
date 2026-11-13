class AddUserToMembers < ActiveRecord::Migration[7.1]
  def change
    add_reference :members, :user,
                  null: true,
                  foreign_key: true,
                  index: { unique: true }
  end
end
