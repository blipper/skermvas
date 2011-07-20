class Addheightwidth < ActiveRecord::Migration
  def up
    change_table :captures do |t|
      t.add :pngwidth, :integer
      t.add :pngheight, :integer
    end
  end

  def down
  end
end
