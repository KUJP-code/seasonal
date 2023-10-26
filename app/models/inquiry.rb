# frozen_string_literal: true

class Inquiry < ApplicationRecord
  belongs_to :setsumeikai

  enum :referrer, 'チラシ' => 0,
                  '口コミ' => 1,
                  'ホームページ' => 2,
                  '看板' => 3,
                  '資料' => 4,
                  'その他' => 5
end
