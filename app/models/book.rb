class Book < ApplicationRecord
  belongs_to :author
  has_many :borrowings, dependent: :restrict_with_error
end
