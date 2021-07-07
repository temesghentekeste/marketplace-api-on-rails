class Api::V1::ProductsController < ApplicationController
    before_action :set_product, only: %i[show update destroy]
    before_action :check_login, only: %i[create] 
    before_action :check_owner, only: %i[update destroy]

    def index 
        products = Product.all 

        render json: products
    end

    def show
        options = { include: [:user]}
        render json: ProductSerializer.new(@product, options).serializable_hash
    end

    def create
        product = current_user.products.build(product_params)

        if product.save
            render json: ProductSerializer.new(product).serializable_hash, status: :created
        else
            render json: { errors: product.errors }, status: :unprocessable_entity
        end

    end

    def update
        if @product.update(product_params)
            render json: ProductSerializer.new(@product).serializable_hash

        else
            render json: @product.errors, status: :unprocessable_entity
        end
    end

    def destroy
        if @product.destroy
            head :no_content
        else
            render json: @product.errors, status: :forbidden
        end
    end


    private

    def product_params
        params.require(:product).permit(:title, :price, :published)
    end

    def set_product
        @product = Product.find(params[:id])
    end

    def check_owner
        head :forbidden unless @product.user_id == current_user&.id
    end
end