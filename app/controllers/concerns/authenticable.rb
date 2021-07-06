module Authenticable
    def check_login
        head :forbidden unless self.current_user
    end

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