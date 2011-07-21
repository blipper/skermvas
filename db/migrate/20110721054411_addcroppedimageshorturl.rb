class Addcroppedimageshorturl < ActiveRecord::Migration
  def up
    change_table :captures do |t|
      t.column :croppedshorturl, :string
    end
  end

  def down
  end
end
