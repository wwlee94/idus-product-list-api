require 'csv'
require 'aws-sdk'
# 추가할 컬럼 
# id,thumbnail_520,thumbnail_720,thumbnail_list_320,title,seller,cost,discount_cost,discount_rate,description

dynamodb = Aws::DynamoDB::Resource.new(region: 'ap-northeast-2')
table = dynamodb.table('idus-api-prod-products')

product_list = CSV.parse(File.read('idus_item_list.csv'), headers:true)
product_list.each do |product|
    table.put_item({
        item: {
            id: product["id"],
            title: product["title"],
            seller: product["seller"],
            thumbnail_520: product["thumbnail_520"],
            thumbnail_720: product["thumbnail_720"],
            thumbnail_list_320: product["thumbnail_list_320"],
            cost: product["cost"],
            discount_cost: product["discount_cost"],
            discount_rate: product["discount_rate"],
            description: product["description"]
        }
    })    
    puts(product["title"] + ' 추가 성공 !!')
end