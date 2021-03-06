require 'aws-sdk'
# dynamodb = Aws::DynamoDB::Resource.new(region: 'ap-northeast-2')
# table = dynamodb.table('idus-api-prod-products')

# scan_output = table.scan({
#   limit: 50,
#   select: "ALL_ATTRIBUTES"
# })

# scan_output.items.each do |item|
#     keys = item.keys
#     keys.each do |k|
#         puts "#{k} : #{item[k]}"
#         puts item[k].class
#     end
# end
dynamodb = Aws::DynamoDB::Client.new
params = {
    table_name: 'idus-api-prod-products',
    key_condition_expression: "stat = :stat and id = :id",
    expression_attribute_values: {
        ":stat" => "ok",
        ":id" => 1
    }
}
result = dynamodb.query(params)
puts result.items