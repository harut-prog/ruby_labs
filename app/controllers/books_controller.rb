class BooksController < ApplicationController
  before_action :require_librarian!, except: %i[index show]

  def index
    @books = Book.includes(:author).joins(:author)

    if params[:query].present?
      query = "%#{Book.sanitize_sql_like(params[:query])}%"
      @books = @books.where(
        'books.title ILIKE :q OR books.isbn ILIKE :q OR authors.name ILIKE :q',
        q: query
      )
    end

    @books = @books.where(author_id: params[:author_id]) if params[:author_id].present?

    if %w[true false].include?(params[:available])
      @books = @books.where(available: params[:available] == 'true')
    end

    @books = @books.order(:title)
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Запись создана",
                         status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])

    if @book.update(book_params)
      redirect_to @book, notice: "Запись обновлена",
                         status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])

    if @book.destroy
      redirect_to books_path, notice: "Запись удалена",
                              status: :see_other
    else
      redirect_to @book,
                  alert: @book.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :isbn, :published_year, :author_id)
  end
end
