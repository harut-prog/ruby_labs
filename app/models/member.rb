class Member < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true
end
