class Retrievaldatetime < ActiveRecord::Migration
  def up
    change_table :captures do |t|
      t.change :retrievaldate, :datetime
      t.rename :retrievaldate, :retrievaldatetime
    end
  end

  def down
  end
end
