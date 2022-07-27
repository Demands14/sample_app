class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  USER_ATTRS = %i(name email password password_confirmation).freeze

  before_save :downcase_email
  before_create :create_activation_digest

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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.blank?

    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_attribute :activated, true
    touch :activated_at
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute :reset_digest, User.digest(reset_token)
    touch :reset_sent_at
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.user.email.expired.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
