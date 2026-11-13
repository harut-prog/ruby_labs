require "test_helper"

class LibraryTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = false

  setup do
    @author = Author.create!(name: "Тестовый автор")
    @book = Book.create!(title: "Тест", isbn: "test-isbn-1",
      published_year: 2020, author: @author)
    @member = Member.create!(name: "Тест", email: "test-reader@example.org")
  end

  test "isbn must be unique" do
    copy = @book.dup
    assert_not copy.valid?
    assert copy.errors[:isbn].any?
  end

  test "year range" do
    @book.published_year = Date.current.year + 1
    assert_not @book.valid?
    @book.published_year = 999
    assert_not @book.valid?
    @book.published_year = 1000
    assert @book.valid?
  end

  test "due date and return update availability" do
    x = Borrowing.create!(book: @book, member: @member,
      borrowed_on: Date.current)
    assert_equal Date.current + 14, x.due_on
    assert_not @book.reload.available?
    x.update!(returned_on: Date.current)
    assert @book.reload.available?
  end
end
