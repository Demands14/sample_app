class User < ApplicationRecord
  attr_accessor :remember_token

  USER_ATTRS = %i(name email password password_confirmation).freeze

  before_save :downcase_email

  validates :email, presence: true,
            length: {minium: Settings.user.email.min_length,
                     maximum: Settings.user.email.max_length},
            format: {with: Settings.user.valid_email_regex},
            uniqueness: true

  validates :name, presence: true,
            length: {maximum: Settings.user.name.max_length}
  validates :password, presence: true,
            length: {minimum: Settings.user.password.min_length}, if: :password,
            allow_nil: true

  has_secure_password

  scope :name_asc, ->{order(name: :asc)}

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? remember_token
    return false if remember_token.blank?

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  private

  def downcase_email
    email.downcase!
  end
end
