class Borrowing < ApplicationRecord
  belongs_to :book
  belongs_to :member

  validates :borrowed_on, :due_on, presence: true
  validate :dates_order

  private

  def dates_order
    if borrowed_on && due_on && due_on <= borrowed_on
      errors.add(:due_on, "должна быть позже даты выдачи")
    end
  end
end
