# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110721054411) do

  create_table "captures", :id => false, :force => true do |t|
    t.string   "uuid",               :limit => 36
    t.string   "url"
    t.datetime "retrievaldatetime"
    t.string   "sha2"
    t.string   "pdfurl"
    t.string   "htmlurl"
    t.string   "pngurl"
    t.string   "pngthumbnailurl"
    t.string   "publicID"
    t.string   "shorturl"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pngwidth"
    t.integer  "pngheight"
    t.integer  "pngthumbnailwidth"
    t.integer  "pngthumbnailheight"
    t.string   "croppedshorturl"
  end

end
