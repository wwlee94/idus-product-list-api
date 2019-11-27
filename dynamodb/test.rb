require 'aws-sdk'

dynamodb = Aws::DynamoDB::Resource.new(region: 'ap-northeast-2')
table = dynamodb.table('idus-api-prod-products')

scan_output = table.scan({
  limit: 50,
  select: "ALL_ATTRIBUTES"
})

scan_output.items.each do |item|
    keys = item.keys
    keys.each do |k|
        puts "#{k} : #{item[k]}"
        puts item[k].class
    end
end