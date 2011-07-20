class CreateCaptures < ActiveRecord::Migration
  def change
    create_table :captures, :id => false, :primary_key => :uuid do |t|
      t.string :uuid, :limit => 36, :primary => true
      t.string :url
      t.date :retrievaldate
      t.string :sha2
      t.string :pdfurl
      t.string :htmlurl
      t.string :pngurl
      t.string :pngthumbnailurl
      t.string :publicID
      t.string :shorturl
    end
  end
end
