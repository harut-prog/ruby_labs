class WordDocumentsController < ApplicationController
  before_action :require_librarian!

  def library_card
    member = Member.includes(borrowings: :book).find(params[:id])
    rows = member.borrowings.where(returned_on: nil).map do |borrowing|
      [borrowing.book.title, borrowing.borrowed_on.to_s, borrowing.due_on.to_s]
    end

    doc = Caracal::Document.new do |document|
      document.h1 "Читательский билет"
      document.p "Имя: #{member.name}"
      document.p "Email: #{member.email}"
      document.p "Дата формирования: #{Date.current}"
      document.table [["Книга", "Выдана", "Вернуть до"]] + rows
    end

    download(doc, "member_#{member.id}.docx")
  end

  def book_card
    book = Book.includes(:author).find(params[:id])

    doc = Caracal::Document.new do |document|
      document.h1 "Карточка книги"
      document.table [
        ["Название", book.title],
        ["Автор", book.author.name],
        ["ISBN", book.isbn],
        ["Год", book.published_year.to_s],
        ["Статус", book.available? ? "Доступна" : "Выдана"]
      ]
    end

    download(doc, "book_#{book.id}.docx")
  end

  private

  def download(doc, name)
    send_data doc.render.string,
              filename: name,
              disposition: 'attachment',
              type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  end
end
