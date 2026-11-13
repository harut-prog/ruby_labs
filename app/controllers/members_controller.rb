class MembersController < ApplicationController
  before_action :require_librarian!
  def index
    @members = Member.all
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)

    if @member.save
      redirect_to @member, notice: "Запись создана",
                              status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])

    if @member.update(member_params)
      redirect_to @member, notice: "Запись обновлена",
                              status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = Member.find(params[:id])

    if @member.destroy
      redirect_to members_path, notice: "Запись удалена",
                                 status: :see_other
    else
      redirect_to @member,
                  alert: @member.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def member_params
    params.require(:member).permit(:name, :email, :phone)
  end

end
