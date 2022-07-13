class User < ApplicationRecord
  before_save :downcase_email

  validates :email, presence: true,
            length: {minium: Settings.user.email.min_length,
                     maximum: Settings.user.email.max_length},
            format: {with: Settings.user.valid_email_regex},
            uniqueness: {case_sensitive: false}

  validates :name, presence: true,
            length: {maximum: Settings.user.name.max_length}
  validates :password, presence: true,
            length: {minimum: Settings.user.password.min_length}, if: :password

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end
end
