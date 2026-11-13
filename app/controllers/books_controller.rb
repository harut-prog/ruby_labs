class BooksController < ApplicationController
  def index
    @books = Book.includes(:author).order(:title)
  end

  def show
    @book = Book.find(params[:id])
  end
end
