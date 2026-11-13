class Author < ApplicationRecord
  has_many :books, dependent: :restrict_with_error
end
