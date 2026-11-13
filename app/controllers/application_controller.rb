class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def require_librarian!
    head :forbidden unless current_user.librarian?
  end

  def allowed_borrowings
    return Borrowing.all if current_user.librarian?

    Borrowing.where(member_id: current_user.member&.id)
  end
end
