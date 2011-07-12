class Addheightwidth < ActiveRecord::Migration
  def up
    add_column "captures", "pngwidth", :integer
    add_column "captures", "pngheight", :integer
  end

  def down
  end
end
