class Addcookiejar < ActiveRecord::Migration
  def up
    change_table :captures do |t|
      t.column :cookiejar, :string
    end
  end

  def down
  end
end
