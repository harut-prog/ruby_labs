class FilesController < ApplicationController
  skip_before_action :authenticate_user!, only: :cover

  def cover
    deliver(Book.find(params[:id]).cover, false)
  end

  def scan
    m = current_user.librarian? ? Member.find(params[:id]) : current_user.member
    raise ActiveRecord::RecordNotFound unless m && m.id == params[:id].to_i

    response.headers['Cache-Control'] = 'private, no-store'
    deliver(m.id_scan, true)
  end

  def edit
    require_librarian!
  end

  def update
    return head(:forbidden) unless current_user.librarian?

    upload = params.require(:file)
    kinds = {
      'cover' => [Book, :cover, %w[image/png image/jpeg]],
      'scan' => [Member, :id_scan, %w[application/pdf image/png image/jpeg]]
    }
    model, field, types = kinds.fetch(params[:kind])
    return head(:unprocessable_entity) unless types.include?(upload.content_type)
    return head(:unprocessable_entity) if upload.size > 5.megabytes

    record = model.find(params[:id])
    record.public_send(field).attach(upload)
    redirect_to record, status: :see_other
  rescue KeyError
    head :not_found
  end

  private

  def deliver(attachment, private_file)
    raise ActiveRecord::RecordNotFound unless attachment.attached?
    send_file ActiveStorage::Blob.service.path_for(attachment.blob.key),
              filename: attachment.filename.to_s,
              type: attachment.content_type,
              disposition: private_file ? 'attachment' : 'inline'
  end
end
