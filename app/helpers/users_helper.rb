# frozen_string_literal: true

module UsersHelper
  def users_show_button(buttons, query)
    buttons ? buttons.find { |b| b.to_sym == query } : true
  end

  def users_form(user:, buttons: nil)
    render partial: 'form', locals: { user: user, buttons: buttons }
  end
end
