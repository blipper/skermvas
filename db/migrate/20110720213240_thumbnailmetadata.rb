class Thumbnailmetadata < ActiveRecord::Migration
  def up
    add_column "captures", "pngthumbnailwidth", :integer
    add_column "captures", "pngthumbnailheight", :integer
  end

  def down
  end
end
