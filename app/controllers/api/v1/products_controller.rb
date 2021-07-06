class Api::V1::ProductsController < ApplicationController
    before_action :check_login, only: %i[create] 
    def index 
        products = Product.all 

        render json: products
    end

    def show
        product = Product.find(params[:id])

        render json: product
    end

    def create
        product = current_user.products.build(product_params)

        if product.save
            render json: product, status: :created
        else
            render json: { errors: product.errors }, status: :unprocessable_entity\
        end

    end


    private

    def product_params
        params.require(:product).permit(:title, :price, :published)
    end
end
