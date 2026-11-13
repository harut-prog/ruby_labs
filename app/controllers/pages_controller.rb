class PagesController < ApplicationController
  def home
    @books_count = Book.count
    @available_count = Book.where(available: true).count
    active_borrowings = allowed_borrowings.where(returned_on: nil)
    @active_count = active_borrowings.count
    @overdue_count = active_borrowings.where('due_on < ?', Date.current).count
  end

  def about
  end

  def contact
  end
end
