require "test_helper"

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should show products" do
    get api_v1_products_url(), as: :json
    assert_response :success
  end

  test 'should show product' do
    get api_v1_product_url(@product), as: :json
    assert_response :success

    json_response = JSON.parse(response.body, symbolize_names:true)
    assert_equal @product.title, json_response.dig(:data,:attributes, :title)
    assert_equal @product.user.id.to_s, json_response.dig(:data,:relationships, :user, :data, :id)
   
    assert_equal @product.user.email, json_response.dig(:included, 0, :attributes, :email)
  end

  test 'should create product' do
    assert_difference("Product.count") do
      post api_v1_products_url, 
          params: { 
                    product: { 
                              title: @product.title, 
                              price: @product.price, 
                              published: @product.published
                            }
                    },
                    headers: {Authorization: JsonWebToken.encode(user_id: @product.user_id) },
                      as: :json
              
    end
    assert_response :created
  end

  test 'should forbid create product' do
    assert_no_difference("Product.count") do
      post api_v1_products_url,
          params: {
            product: {
              title: @product.title,
              price: @product.price,
              published: @product.published
            }
          }, as: :json
    end
    assert_response :forbidden
  end

  test 'should update product' do
    patch api_v1_product_url(@product),
          params: { product: { title: @product.title }},
          headers: { Authorization: JsonWebToken.encode(user_id: @product.user_id)},
          as: :json
    assert_response :success
  end

  test 'should forbid product update' do
    patch api_v1_product_url(@product),
          params: { product: {title: @product.title }},
          as: :json
    assert_response :forbidden
  end

  test 'should not update product created by other user' do
    patch api_v1_product_url(@product),
          params: { product: { title: @product.title }},
          headers: { Authorization: JsonWebToken.encode(user_id: users(:two).id)},
          as: :json
    assert_response :forbidden
  end

  test 'should destroy product' do
    assert_difference("Product.count", -1) do
      delete api_v1_product_url(@product), 
            headers: { Authorization: JsonWebToken.encode(user_id: @product.user_id)},
            as: :json
    end
    assert_response :no_content
  end

  test 'should forbid destroy product' do
    delete api_v1_product_url(@product), 
           headers: { user_id: JsonWebToken.encode(user_id: users(:two).id)},
           as: :json
    assert_response :forbidden
  end

  test "should filter products by name" do
    assert_equal 2, Product.filter_by_title('tv').count
  end

  test 'should filter products by name and sort them' do
    assert_equal [products(:another_tv), products(:one)],
                                         Product.filter_by_title('tv').sort
  end 

  test 'should filter products by price and sort them' do
    assert_equal [products(:two), products(:one)], 
                                  Product.above_or_equal_to_price(200).sort
  end 

  test 'should filter products by price lower and sort them' do
    assert_equal [products(:two), products(:one)], 
                                  Product.lower_or_equal_to_price(200).sort
  end 

  test 'should sort product by most recent' do
    # we will touch some products to update them
    products(:two).touch
    assert_equal [products(:another_tv), products(:one),products(:two)], Product.recent.to_a
  end
end
