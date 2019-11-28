class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  rescue_from Exceptions::BadRequest, Exceptions::InternalServerError do |e|
    response = { statusCode: e.status, body: e.message }
    render json: JSON.pretty_generate(response)
  end

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
  
    if params[:page]
      puts 'page 변수 존재!' 
      raise Exceptions::ParameterIsNotInteger unless is_number? params[:page]

      page_no = params[:page].to_i
      raise Exceptions::PageUnderRequest if page_no <= 0

      # @products.items.each{ |product|
      #   product.transform_values(&:to_i)
      # }
      start_id = (params[:page].to_i - 1) * 10

      puts('Searching for more ...')

      param[:exclusive_start_key] = {
        id: start_id,
        stat: "ok"
      }

      @products = dynamodb.query(param)

      raise Exceptions::PageOverRequest if @products.items.blank?

      puts @products.items
      puts @products.last_evaluated_key

      response = { statusCode: 200, body: @products.items, last_evaluated_key: @products.last_evaluated_key }
      render json: JSON.pretty_generate(response)

    else
      begin
        @products = dynamodb.query(param)
        response = { statusCode: 200, body: @products.items, last_evaluated_key: @products.last_evaluated_key }
      rescue Aws::DynamoDB::Errors::ServiceError => e
        response = { statusCode: 500, body: "#{e.message}" }
      end

      raise Exceptions::InternalServerError if response.nil?
      
      render json: JSON.pretty_generate(response)
    end

  rescue Exceptions::PageOverRequest => e
    response = { statusCode: 400, body: e.message }
    render json: JSON.pretty_generate(response)
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
      raise Exceptions::ParameterIsNotInteger unless is_number? params[:id]

      id = params[:id].to_i
      # raise Exceptions::BadRequest if id <= 0

      param = {
        table_name: 'idus-api-prod-products',
        key_condition_expression: "stat = :stat and id = :id",
        expression_attribute_values: {
          ":stat" => "ok",
          ":id" => id
        }
      }
      begin
        @product = dynamodb.query(param)
      rescue Aws::DynamoDB::Errors::ServiceError => error
        response = { statusCode: 500, body: "#{error.message}"} 
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
