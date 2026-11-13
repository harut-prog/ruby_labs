class ReportsController < ApplicationController
 before_action :require_librarian!

 def borrowings
 @rows = Borrowing.includes(:member, :book).order(:id)
 respond_to { |f| f.xlsx }
 end

 def overdue
 @rows = Borrowing.includes(:member, :book)
 .where(returned_on: nil).where("due_on < ?", Date.current)
 respond_to { |f| f.xlsx }
 end
end
