class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  rescue_from Exceptions::BadRequest, Exceptions::NotFound, Exceptions::InternalServerError do |e|
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
      limit: 50
    }
  
    # 페이지 변수가 있을 때
    if params[:page]
      raise Exceptions::ParameterIsNotInteger unless is_number? params[:page]

      page_no = params[:page].to_i
      raise Exceptions::PageUnderRequest if page_no <= 0

      start_id = (params[:page].to_i - 1) * 50

      puts('Searching for more ...')

      param[:exclusive_start_key] = {
        id: start_id,
        stat: "ok"
      }

      begin
        @products = dynamodb.query(param)
        puts @products.items
        puts @products.last_evaluated_key
        raise Exceptions::PageOverRequest if @products.items.blank?
        @products.items.each do |item|
          str_int = item['id']
          item['id'] = str_int.to_i
        end
        response = { statusCode: 200, body: @products.items }
      rescue Aws::DynamoDB::Errors::ServiceError => e
        response = { statusCode: 500, body: "#{e.message}" }
      end

      raise Exceptions::InternalServerError if response.nil?

      render json: JSON.pretty_generate(response)
    else
      # 페이지 변수 없을 때 첫 50개 데이터만 보여줌
      begin
        @products = dynamodb.query(param)
        @products.items.each do |item|
          str_int = item['id']
          item['id'] = str_int.to_i
        end
        response = { statusCode: 200, body: @products.items }
      rescue Aws::DynamoDB::Errors::ServiceError => e
        response = { statusCode: 500, body: "#{e.message}" }
      end

      raise Exceptions::InternalServerError if response.nil?
      
      render json: JSON.pretty_generate(response)
    end
  end

  # GET /products/1
  def show
    raise Exceptions::ProductNotFound if @product.items.blank?
    str_int = @product.items[0]['id']
    @product.items[0]['id'] = str_int.to_i
    response = { statusCode: 200, body: @product.items }
    render json: JSON.pretty_generate(response)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      dynamodb = Aws::DynamoDB::Client.new
      raise Exceptions::ParameterIsNotInteger unless is_number? params[:id]

      id = params[:id].to_i

      param = {
        table_name: 'idus-api-prod-products',
        projection_expression: "id, title, seller, thumbnail_720, thumbnail_list_320, cost, discount_cost, discount_rate, description",
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
