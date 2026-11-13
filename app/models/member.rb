class Member < ApplicationRecord
  has_one_attached :id_scan
  belongs_to :user, optional: true
  has_many :borrowings, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true
end
