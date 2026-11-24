# frozen_string_literal: true

require 'capybara/selenium/driver'

# Capybara 3.40 (latest) resets Chrome between specs with the CDP command
# Storage.clearDataForOrigin(origin: '*'). Chrome 158+ rejects '*' as an origin
# ("invalid argument: * is not a valid URL"), failing every JS system spec.
# Clear cookies browser-wide and storage for the app server's real origin instead.
module CapybaraChromeResetFix
  def execute_cdp(cmd, **params)
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    origin = Capybara.current_session.server&.base_url
    super(cmd, **params, origin:) if origin
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetFix)
