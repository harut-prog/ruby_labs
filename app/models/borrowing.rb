class Borrowing < ApplicationRecord
  belongs_to :book
  belongs_to :member

  accepts_nested_attributes_for :member, reject_if: :all_blank

  validates :borrowed_on, :due_on, presence: true
  validate :dates_order

  before_validation :set_due_on, on: :create

  after_save :refresh_availability
  after_destroy :refresh_availability

  private

  def set_due_on
    self.due_on ||= borrowed_on + 14.days if borrowed_on
  end

  def refresh_availability
    ids = [book_id, book_id_before_last_save].compact.uniq

    Book.where(id: ids).each do |book|
      book.update!(available: !book.borrowings.where(returned_on: nil).exists?)
    end
  end

  def dates_order
    return unless borrowed_on && due_on && due_on <= borrowed_on

    errors.add(:due_on, 'должна быть позже даты выдачи')
  end
end
