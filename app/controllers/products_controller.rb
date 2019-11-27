class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  def index
    dynamodb = Aws::DynamoDB::Client.new

    param = {
      table_name: 'idus-api-prod-products',
      projection_expression: "id, title, seller, thumbnail_520",
      key_condition_expression: "stat = :stat",
      expression_attribute_values: {
        ":stat" => "ok"
      },
      limit: 10
    }

    if params[:page].to_i > 1
      puts 'page 변수 존재!' 
      # @products.items.each{ |product|
      #   product.transform_values(&:to_i)
      # }
      start_id = (params[:page].to_i - 1) * 10
      puts start_id
      puts('Scanning for more ...')

      param[:exclusive_start_key] = {
        id: start_id,
        stat: "ok"
      }

      @products = dynamodb.query(param)

      puts @products.items
      puts @products.last_evaluated_key

      response = { statusCode: 200, body: @products.items, last_evaluated_key: @products.last_evaluated_key }
      render json: JSON.pretty_generate(response)

    else
      begin
        @products = dynamodb.query(param)
        response = { statusCode: 200, body: @products.items, last_evaluated_key: @products.last_evaluated_key }
      rescue Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to query index:"
        puts "#{error.message}"
        response = { statusCode: 500, body: "#{error.message}" }
      end

      response = { statusCode: 500, body: "interval server error !!" } if response.nil?
      
      render json: JSON.pretty_generate(response)
    end
  end

  # GET /products/1
  def show
    response = { statusCode: 200, body: @product.items }
    render json: JSON.pretty_generate(response)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      dynamodb = Aws::DynamoDB::Client.new
      if is_number? params[:id]
        param = {
          table_name: 'idus-api-prod-products',
          key_condition_expression: "stat = :stat and id = :id",
          expression_attribute_values: {
            ":stat" => "ok",
            ":id" => params[:id].to_i
          }
        }
        begin
          @product = dynamodb.query(param)
        rescue Aws::DynamoDB::Errors::ServiceError => error
          puts "Unable to query show:"
          puts "#{error.message}"
          response = { statusCode: 500, body: "#{error.message}"} 
          render json: JSON.pretty_generate(response)
        end
      else
        message = "'params[:id]' is not Integer !!"
        puts message
        response = { statusCode: 400, body: message }
        render json: JSON.pretty_generate(response)
      end
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:stat, :id, :title, :seller, :thumbnail_520, :thumbnail_720, :thumbnail_list_320, :cost, :discount_cost, :discount_rate, :description, :page)
    end

    def is_number? string
      true if Integer(string) rescue false
    end
end
