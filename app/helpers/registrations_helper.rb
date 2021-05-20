# frozen_string_literal: true

module RegistrationsHelper
  def social_signin_enabled?
    ::Gitlab.dev_env_or_com? &&
      omniauth_enabled? &&
      devise_mapping.omniauthable? &&
      button_based_providers_enabled?
  end

  def signup_username_data_attributes
    {
      min_length: User::MIN_USERNAME_LENGTH,
      min_length_message: s_('SignUp|Username is too short (minimum is %{min_length} characters).') % { min_length: User::MIN_USERNAME_LENGTH },
      max_length: User::MAX_USERNAME_LENGTH,
      max_length_message: s_('SignUp|Username is too long (maximum is %{max_length} characters).') % { max_length: User::MAX_USERNAME_LENGTH },
      qa_selector: 'new_user_username_field'
    }
  end
end

RegistrationsHelper.prepend_mod_with('RegistrationsHelper')
