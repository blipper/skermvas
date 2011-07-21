class Addheightwidth < ActiveRecord::Migration
  def up
    change_table :captures do |t|
      t.column :pngwidth, :integer
      t.column :pngheight, :integer
    end
  end

  def down
  end
end
