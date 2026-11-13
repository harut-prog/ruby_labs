class Author < ApplicationRecord
  has_many :books, dependent: :restrict_with_error
  accepts_nested_attributes_for :books, reject_if: :all_blank
  validates :name, presence: true
end
