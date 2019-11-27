class Product < ApplicationItem
    partition_key "stat"
    column :title ,:seller, :thumbnail_520, :thumbnail_720, :thumbnail_list_320, :cost, :discount_cost, :discount_rate, :description
    # include Aws::Record
    # integer_attr :id , range_key: true
    # string_attr :stat , hash_key: true 
    # string_attr :title
    # string_attr :seller 
    # string_attr :thumbnail_520
    # string_attr :thumbnail_720
    # string_attr :thumbnail_list_320
    # string_attr :cost
    # string_attr :discount_cost
    # string_attr :discount_rate
    # string_attr :description
end
