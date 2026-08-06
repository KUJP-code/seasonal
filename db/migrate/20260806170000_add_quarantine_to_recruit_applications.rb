# frozen_string_literal: true

class AddQuarantineToRecruitApplications < ActiveRecord::Migration[7.1]
  def up
    change_table :recruit_applications, bulk: true do |t|
      t.boolean :quarantined, null: false, default: false
      t.string :quarantine_reason
      t.datetime :quarantined_at
      t.index :quarantined
    end

    execute <<~SQL.squish
      UPDATE recruit_applications
      SET quarantined = TRUE,
          quarantine_reason = 'Spam origin detected',
          quarantined_at = created_at
      WHERE regexp_replace(lower(COALESCE(nationality, '')), '[^a-z]', '', 'g') ~ '(fuck|cunt|cock)'
    SQL
  end

  def down
    change_table :recruit_applications, bulk: true do |t|
      t.remove_index :quarantined
      t.remove :quarantined_at, :quarantine_reason, :quarantined
    end
  end
end
