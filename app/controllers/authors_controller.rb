class AuthorsController < ApplicationController
  before_action :require_librarian!, except: [:index, :show]
  def index
    @authors = Author.all
  end

  def show
    @author = Author.find(params[:id])
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to @author, notice: "Запись создана",
                              status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @author = Author.find(params[:id])
  end

  def update
    @author = Author.find(params[:id])

    if @author.update(author_params)
      redirect_to @author, notice: "Запись обновлена",
                              status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @author = Author.find(params[:id])

    if @author.destroy
      redirect_to authors_path, notice: "Запись удалена",
                                 status: :see_other
    else
      redirect_to @author,
                  alert: @author.errors.full_messages.to_sentence,
                  status: :see_other
    end
  end

  private

  def author_params
    params.require(:author).permit(:name, :biography)
  end

end
