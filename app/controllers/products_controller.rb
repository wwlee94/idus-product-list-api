class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  def index
    puts 'page 변수 존재!' if params[:page]
  
    dynamodb = Aws::DynamoDB::Client.new

    param = {
      table_name: 'idus-api-prod-products',
      projection_expression: "id, title, seller, thumbnail_520",
      key_condition_expression: "stat = :stat",
      expression_attribute_values: {
        ":stat" => "ok"
      },
      # page_size: 10
      limit: 10
    }

    product_list = []
    begin
      @products = dynamodb.query(param)
      
      # @products.items.each{ |product|
      #   product.transform_values(&:to_i)
      # }
        # product_list.push(@products.as_json)
      # loop do 
      #   @products = dynamodb.scan(params)
      #   break if @products.last_evaluated_key.nil?

      #   puts('Scanning for more ...')
      #   params[:exclusive_start_key] = @products.last_evaluated_key

      #   # product_list.push(@products.as_json)
      # end
    rescue Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to query index:"
      puts "#{error.message}"
      
      render json: { statusCode: 500, body: "#{error.message}"}
    end

    # @products = Product.scan(params)
    response = { statusCode: 200, body: @products.items }
    render json: JSON.pretty_generate(response)
  end

  # GET /products/1
  def show
    response = { statusCode: 200, body: @product.items }
    render json: JSON.pretty_generate(response)
  end

  # # POST /products
  # def create
  #   @product = Product.new(product_params)

  #   if @product.save
  #     render json: @product, status: :created
  #   else
  #     render json: @product.errors, status: :unprocessable_entity
  #   end
  # end

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
          render json: { statusCode: 500, body: "#{error.message}"}
        end
      else
        message = "'params[:id]' is not Integer !!"
        puts message
        render json: { statusCode: 400, body: message }
      end
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:stat, :id, :title, :seller, :thumbnail_520, :thumbnail_720, :thumbnail_list_320, :cost, :discount_cost, :discount_rate, :description)
    end

    def is_number? string
      true if Integer(string) rescue false
    end
end
