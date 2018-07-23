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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180723204820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "business_units", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_business_units_on_code"
  end

  create_table "chopped_bulk_freights", force: :cascade do |t|
    t.string "operation"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["upload_id"], name: "index_chopped_bulk_freights_on_upload_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["code"], name: "index_cities_on_code"
    t.index ["upload_id"], name: "index_cities_on_upload_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_contacts_on_customer_id"
  end

  create_table "costs", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "dist_center_id"
    t.decimal "base_price"
    t.string "currency"
    t.decimal "suggested_markup"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount_for_price"
    t.boolean "updated_cost"
    t.decimal "last_month_base_price"
    t.decimal "last_month_fob_net"
    t.string "product_analyst"
    t.string "commentary"
    t.string "on_demand"
    t.boolean "frac_emb"
    t.string "source_adjustment"
    t.string "competition_adjustment"
    t.string "lead_time"
    t.string "min_order_quantity"
    t.bigint "upload_id"
    t.index ["dist_center_id"], name: "index_costs_on_dist_center_id"
    t.index ["product_id"], name: "index_costs_on_product_id"
    t.index ["upload_id"], name: "index_costs_on_upload_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code"
  end

  create_table "customers", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id"
    t.bigint "city_id"
    t.string "cnpj"
    t.string "contact"
    t.string "display_name"
    t.bigint "upload_id"
    t.string "old_code"
    t.index ["city_id"], name: "index_customers_on_city_id"
    t.index ["code"], name: "index_customers_on_code"
    t.index ["country_id"], name: "index_customers_on_country_id"
    t.index ["upload_id"], name: "index_customers_on_upload_id"
  end

  create_table "dist_centers", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "city_id"
    t.index ["city_id"], name: "index_dist_centers_on_city_id"
    t.index ["code"], name: "index_dist_centers_on_code"
  end

  create_table "emails", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "customer_id"
    t.string "recipient"
    t.string "subject"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_emails_on_customer_id"
    t.index ["user_id"], name: "index_emails_on_user_id"
  end

  create_table "emails_quotes", id: false, force: :cascade do |t|
    t.bigint "email_id", null: false
    t.bigint "quote_id", null: false
    t.index ["email_id", "quote_id"], name: "index_emails_quotes_on_email_id_and_quote_id"
    t.index ["quote_id", "email_id"], name: "index_emails_quotes_on_quote_id_and_email_id"
  end

  create_table "especial_packed_freights", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.bigint "vehicle_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.string "subtype"
    t.index ["upload_id"], name: "index_especial_packed_freights_on_upload_id"
    t.index ["vehicle_id"], name: "index_especial_packed_freights_on_vehicle_id"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.decimal "value"
    t.date "rate_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "icms_taxes", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["upload_id"], name: "index_icms_taxes_on_upload_id"
  end

  create_table "normal_bulk_freights", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.bigint "vehicle_id"
    t.decimal "amount"
    t.decimal "toll"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["upload_id"], name: "index_normal_bulk_freights_on_upload_id"
    t.index ["vehicle_id"], name: "index_normal_bulk_freights_on_vehicle_id"
  end

  create_table "normal_packed_freights", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.string "category"
    t.decimal "amount"
    t.decimal "insurance"
    t.decimal "gris"
    t.decimal "toll"
    t.decimal "ct_e"
    t.decimal "min"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["upload_id"], name: "index_normal_packed_freights_on_upload_id"
  end

  create_table "optimal_markups", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "customer_id"
    t.bigint "dist_center_id"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "table_value"
    t.bigint "business_unit_id"
    t.string "metodology"
    t.bigint "upload_id"
    t.index ["business_unit_id"], name: "index_optimal_markups_on_business_unit_id"
    t.index ["customer_id"], name: "index_optimal_markups_on_customer_id"
    t.index ["dist_center_id"], name: "index_optimal_markups_on_dist_center_id"
    t.index ["product_id"], name: "index_optimal_markups_on_product_id"
    t.index ["upload_id"], name: "index_optimal_markups_on_upload_id"
  end

  create_table "packagings", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.decimal "capacity"
    t.decimal "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["upload_id"], name: "index_packagings_on_upload_id"
  end

  create_table "product_bulk_freights", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.bigint "vehicle_id"
    t.decimal "amount"
    t.bigint "product_id"
    t.decimal "toll"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["product_id"], name: "index_product_bulk_freights_on_product_id"
    t.index ["upload_id"], name: "index_product_bulk_freights_on_upload_id"
    t.index ["vehicle_id"], name: "index_product_bulk_freights_on_vehicle_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "sku"
    t.string "name"
    t.string "unit"
    t.decimal "ipi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "density"
    t.boolean "resolution13"
    t.integer "origin"
    t.string "ncm"
    t.string "display_name"
    t.bigint "upload_id"
    t.index ["sku"], name: "index_products_on_sku"
    t.index ["upload_id"], name: "index_products_on_upload_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "customer_id"
    t.bigint "product_id"
    t.datetime "quote_date"
    t.boolean "icms_padrao"
    t.decimal "icms"
    t.decimal "ipi"
    t.boolean "pis_confins_padrao"
    t.decimal "pis_confins"
    t.string "freight_condition"
    t.decimal "brl_usd"
    t.decimal "brl_eur"
    t.decimal "quantity"
    t.string "unit"
    t.decimal "unit_price"
    t.decimal "markup"
    t.boolean "fixed_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "dist_center_id"
    t.bigint "city_id"
    t.bigint "optimal_markup_id"
    t.bigint "cost_id"
    t.decimal "fob_net_price"
    t.decimal "final_freight"
    t.string "comment"
    t.decimal "unit_freight"
    t.integer "payment_term"
    t.string "freight_base_type"
    t.string "freight_subtype"
    t.bigint "vehicle_id"
    t.bigint "upload_id"
    t.string "currency"
    t.boolean "freight_padrao"
    t.boolean "watched"
    t.boolean "current"
    t.string "payment_term_description"
    t.string "product_alias"
    t.string "code"
    t.index ["city_id"], name: "index_quotes_on_city_id"
    t.index ["cost_id"], name: "index_quotes_on_cost_id"
    t.index ["customer_id"], name: "index_quotes_on_customer_id"
    t.index ["dist_center_id"], name: "index_quotes_on_dist_center_id"
    t.index ["optimal_markup_id"], name: "index_quotes_on_optimal_markup_id"
    t.index ["product_id"], name: "index_quotes_on_product_id"
    t.index ["upload_id"], name: "index_quotes_on_upload_id"
    t.index ["user_id"], name: "index_quotes_on_user_id"
    t.index ["vehicle_id"], name: "index_quotes_on_vehicle_id"
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "sale_date"
    t.bigint "customer_id"
    t.bigint "product_id"
    t.bigint "dist_center_id"
    t.bigint "user_id"
    t.bigint "business_unit_id"
    t.string "moneda"
    t.string "unit"
    t.decimal "volume"
    t.decimal "base_price"
    t.decimal "unit_price"
    t.string "calculated"
    t.decimal "markup"
    t.string "comentario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["business_unit_id"], name: "index_sales_on_business_unit_id"
    t.index ["customer_id"], name: "index_sales_on_customer_id"
    t.index ["dist_center_id"], name: "index_sales_on_dist_center_id"
    t.index ["product_id"], name: "index_sales_on_product_id"
    t.index ["upload_id"], name: "index_sales_on_upload_id"
    t.index ["user_id"], name: "index_sales_on_user_id"
  end

  create_table "system_variables", force: :cascade do |t|
    t.string "name"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tax_rules", force: :cascade do |t|
    t.string "tax_type"
    t.bigint "customer_id"
    t.bigint "product_id"
    t.string "origin"
    t.string "destination"
    t.decimal "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.index ["customer_id"], name: "index_tax_rules_on_customer_id"
    t.index ["product_id"], name: "index_tax_rules_on_product_id"
    t.index ["upload_id"], name: "index_tax_rules_on_upload_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.string "filename"
    t.string "model"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_uploads_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.string "role"
    t.boolean "active"
    t.bigint "business_unit_id"
    t.bigint "supervisor_id"
    t.index ["business_unit_id"], name: "index_users_on_business_unit_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["supervisor_id"], name: "index_users_on_supervisor_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "upload_id"
    t.boolean "active", default: true
    t.index ["name"], name: "index_vehicles_on_name"
    t.index ["upload_id"], name: "index_vehicles_on_upload_id"
  end

  add_foreign_key "contacts", "customers"
  add_foreign_key "costs", "dist_centers"
  add_foreign_key "costs", "products"
  add_foreign_key "emails", "customers"
  add_foreign_key "emails", "users"
  add_foreign_key "especial_packed_freights", "vehicles"
  add_foreign_key "normal_bulk_freights", "vehicles"
  add_foreign_key "optimal_markups", "customers"
  add_foreign_key "optimal_markups", "dist_centers"
  add_foreign_key "optimal_markups", "products"
  add_foreign_key "product_bulk_freights", "products"
  add_foreign_key "product_bulk_freights", "vehicles"
  add_foreign_key "quotes", "customers"
  add_foreign_key "quotes", "products"
  add_foreign_key "quotes", "users"
  add_foreign_key "sales", "business_units"
  add_foreign_key "sales", "customers"
  add_foreign_key "sales", "dist_centers"
  add_foreign_key "sales", "products"
  add_foreign_key "tax_rules", "customers"
  add_foreign_key "tax_rules", "products"
end
