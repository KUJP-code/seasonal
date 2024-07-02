# frozen_string_literal: true

module DocumentUploadsHelper
  def category_or_other(doc_upload)
    if doc_upload.other?
      doc_upload.other_description
    else
      t(".#{doc_upload.category}")
    end
  end
end
