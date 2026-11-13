class User < ApplicationRecord
  has_one :member

  validates :role, inclusion: { in: %w[reader librarian] }

  def librarian?
    role == 'librarian'
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
end
