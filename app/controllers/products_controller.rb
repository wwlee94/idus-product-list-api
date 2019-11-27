class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  Aws.config.update({
    region: "ap-northeast-2",
    endpoint: "http://dynamodb.ap-northeast-2.amazonaws.com"
  })

  # GET /products
  def index
    puts 'page 변수 존재!' if params[:page]
  
    dynamodb = Aws::DynamoDB::Client.new

    params = {
      table_name: 'idus-api-prod-products',
      projection_expression: "id, title, seller, thumbnail_520",
      limit: 50
    }

    product_list = []
    begin
      @products = dynamodb.scan(params)
  
        # product_list.push(@products.as_json)
      # loop do 
      #   @products = dynamodb.scan(params)
      #   break if @products.last_evaluated_key.nil?

      #   puts('Scanning for more ...')
      #   params[:exclusive_start_key] = @products.last_evaluated_key

      #   # product_list.push(@products.as_json)
      # end
    rescue Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to scan:"
      puts "#{error.message}"
      render json: JSON.pretty_generate({ statusCode: 500, body: "#{error.message}"})
    end

    # @products = Product.scan(params)
    response = { statusCode: 200, body: @products}
    render json: JSON.pretty_generate(response)
  end

  # GET /products/1
  def show
    response = { statusCode: 200, body: @product.as_json }
    render json: JSON.pretty_generate(response)
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # # PATCH/PUT /products/1
  # def update
  #   if @product.update(product_params)
  #     render json: @product
  #   else
  #     render json: @product.errors, status: :unprocessable_entity
  #   end
  # end

  # # DELETE /products/1
  # def delete
  #   @product.destroy
  #   render json: {deleted: true}
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:id, :title, :seller, :thumbnail_520, :thumbnail_720, :thumbnail_list_320, :cost, :discount_cost, :discount_rate, :description)
    end
end
