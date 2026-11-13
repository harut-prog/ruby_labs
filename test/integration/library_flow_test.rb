require "test_helper"

class LibraryFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @staff = User.create!(email: "staff-test@example.org", role: "librarian",
      password: "test-password-123")
    @reader = User.create!(email: "reader-test@example.org", role: "reader",
      password: "test-password-123")
    a = Author.create!(name: "Автор теста")
    @book = Book.create!(title: "Книга теста", isbn: "flow-isbn",
      published_year: 2020, author: a)
  end

  test "librarian creates borrowing and nested member" do
    sign_in @staff
    assert_difference('Borrowing.count', 1) do
      post borrowings_path, params: {borrowing: {book_id: @book.id,
          borrowed_on: Date.current, member_attributes: {
            name: "Новый", email: "new-test@example.org"}}}
    end
    assert_redirected_to borrowing_path(Borrowing.last)
  end

  test "reader cannot create borrowing" do
    sign_in @reader
    assert_no_difference('Borrowing.count') do
      post borrowings_path, params: {borrowing: {book_id: @book.id}}
    end
    assert_response :forbidden
  end

  test "reader sees catalog" do
    sign_in @reader
    get books_path
    assert_response :success
    assert_select 'h1', 'Каталог книг'
  end
end
