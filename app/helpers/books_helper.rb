module BooksHelper

  def book_status(book)
    book.available? ? 'Доступна' : 'Выдана'
  end
end
