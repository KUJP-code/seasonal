class AddCloseAtAndEleKindyModifierToTimeSlot < ActiveRecord::Migration[7.1]
  def change
    add_column :time_slots, :close_at, :datetime, default: 'Fri, 05 Jan 2024 15:54:41.585798000 JST +09:00'
    add_column :time_slots, :ele_modifier, :integer, default: 0
    add_column :time_slots, :kindy_modifier, :integer, default: 0
  end
end
