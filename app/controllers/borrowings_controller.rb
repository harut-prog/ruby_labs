class BorrowingsController < ApplicationController
  before_action :load_choices, only: %i[new create edit update]

  def index
    @borrowings = Borrowing.includes(:book, :member)
  end

  def show
    @borrowing = Borrowing.find(params[:id])
  end

  def new
    @borrowing = Borrowing.new(borrowed_on: Date.current)
  end

  def edit
    @borrowing = Borrowing.find(params[:id])
  end

  def create
    @borrowing = Borrowing.new(borrowing_params)
    persist(:new)
  end

  def update
    @borrowing = Borrowing.find(params[:id])
    @borrowing.assign_attributes(borrowing_params)
    persist(:edit)
  end

  private

  def persist(template)
    Book.transaction do
      @borrowing.book&.lock!

      active = @borrowing.book&.borrowings
                         &.where(returned_on: nil)
                         &.where&.not(id: @borrowing.id)
                         &.exists?

      if @borrowing.returned_on.nil? && active
        @borrowing.errors.add(:base, 'Книга уже выдана')
      elsif @borrowing.save
        redirect_to @borrowing, status: :see_other
        return
      end

      render template, status: :unprocessable_entity
    end
  end

  def load_choices
    @books = Book.order(:title)
    @members = Member.order(:name)
  end

  def borrowing_params
    params.require(:borrowing).permit(
      :book_id,
      :member_id,
      :borrowed_on,
      :due_on,
      :returned_on
    )
  end
end
