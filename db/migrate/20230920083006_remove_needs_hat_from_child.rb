class RemoveNeedsHatFromChild < ActiveRecord::Migration[7.0]
  change_table :children do |t|
    t.remove :needs_hat
  end
end
