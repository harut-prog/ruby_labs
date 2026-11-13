class Member < ApplicationRecord
  belongs_to :user, optional: true
  has_many :borrowings, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true
end
