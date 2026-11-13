class Book < ApplicationRecord
  has_one_attached :cover
  belongs_to :author
  has_many :borrowings, dependent: :restrict_with_error

  validates :isbn, presence: true, uniqueness: true
  validates :published_year, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1000,
    less_than_or_equal_to: ->(_) { Date.current.year }
  }
end
