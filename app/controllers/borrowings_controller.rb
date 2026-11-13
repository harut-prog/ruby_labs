class BorrowingsController < ApplicationController
  def index
    @borrowings = Borrowing.all
  end

  def show
    @borrowing = Borrowing.find(params[:id])
  end
end
