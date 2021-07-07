class User < ApplicationRecord
    has_secure_password

    has_many :products, dependent: :destroy
    has_many :orders, dependent: :destroy

    validates :email, uniqueness: true
    validates_format_of :email, with: /@/
    # validates :password, presence: true
end
