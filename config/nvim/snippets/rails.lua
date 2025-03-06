local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("ruby", {
  s("rcont", { -- Rails Controller
    t({ "class " }), i(1, "ControllerName"), t({ " < ApplicationController", "" }),
    t({ "  def " }), i(2, "index"), t({ "", "    @"), i(3, "objects"), t(" = "), i(4, "Model.all"),
    t({ "", "  end", "", "end" }),
  }),

  s("rmodel", { -- Rails Model
    t({ "class " }), i(1, "ModelName"), t({ " < ApplicationRecord", "" }),
    t({ "  validates :" }), i(2, "field"), t({ ", presence: true" }),
    t({ "", "end" }),
  }),

  s("rmigr", { -- Rails Migration
    t({ "class " }), i(1, "MigrationName"), t({ " < ActiveRecord::Migration[" }), i(2, "6.1"), t({ "]", "" }),
    t({ "  def change", "" }),
    t({ "    create_table :" }), i(3, "table_name"), t({ " do |t|" }),
    t({ "      t." }), i(4, "string"), t(" :"), i(5, "column_name"),
    t({ "", "      t.timestamps", "    end", "  end", "end" }),
  }),
})
