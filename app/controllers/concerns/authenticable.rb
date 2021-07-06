module Authenticable
    def current_user
        # TODO
        # byebug
        return @current_user if @current_user

        header = request.headers['Authorization']

        return nil if header.nil?
        
        decoded = JsonWebToken.decode(header.split(" ").last)
        @current_user = User.find(decoded[:user_id]) rescue ActiveRecord::RecordNotFound
    end
end