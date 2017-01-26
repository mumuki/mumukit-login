[![Stories in Ready](https://badge.waffle.io/mumuki/mumukit-login.png?label=ready&title=Ready)](https://waffle.io/mumuki/mumukit-login)
[![Build Status](https://travis-ci.org/mumuki/mumukit-login.svg?branch=master)](https://travis-ci.org/mumuki/mumukit-login)
[![Code Climate](https://codeclimate.com/github/mumuki/mumukit-login/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumukit-login)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumukit-login/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumukit-login)

# Mumukit::Login

> Omniauth-based login library for Mumuki Platform

## Core components

![](http://www.plantuml.com/plantuml/png/dL5B3e903DtFARW0nWCO4pznfT702IPGiM6OciwW2_NkYW65SJ3efek-J_lQH4bZWarPb3dQDMMedoK6Qr5d9hW8SHCY-M1j6HyrWXGP4ajS4xzImcd7Oa7QCYa5x1lmHZtMBJ1CwQmTvnNB0ix4kH2eBV1U9k0dzEPR4HSrA3xwlfaxfXEcZoo3sAtiW_YTfpWRlR9ChgFG7pEIgCpFgXYrj2pxZjWazlpd1KskeUFUG7Dfm2-ga4herotX18gEpk66QMDPg3zaiz8UndS0)

<!--

@startuml
class MumukitLoginLoginSettings {

}

class MumukitLoginOriginRedirector {

}

MumukitLoginOriginRedirector -> MumukitLoginController

class MumukitLoginController {

}

MumukitLoginController -down-> MumukitLoginFramework

interface MumukitLoginFramework {

}

class MumukitLoginForm {

}


MumukitLoginForm -down-> MumukitLoginProvider
MumukitLoginForm -down-> MumukitLoginController
MumukitLoginForm -down-> MumukitLoginLoginSettings

MumukitLoginFramework <|.- MumukitLoginFrameworkRails
MumukitLoginFramework <|.- MumukitLoginFrameworkSinatra

interface MumukitLoginProvider {

}

MumukitLoginProvider <|-.- MumukitLoginProviderBase

MumukitLoginProviderBase <|-- MumukitLoginProviderDeveloper
MumukitLoginProviderBase <|-- MumukitLoginProviderSaml
MumukitLoginProviderBase <|-- MumukitLoginProviderAuth0
@enduml

-->

## Helpers

![](http://www.plantuml.com/plantuml/png/Iyv9B2vMy2tDBStEBF79Jy_CSomjoKZDAybCJYp9pC_pICqfI2qgLgZcKb0eoyzCKKX4IASgQcW2XPFoytCKaakBYe32yQN5gKNsOE5G80j562XQ2m00)

## Usage

### Rails

```ruby
# in initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
   Mumukit::Login.configure_omniauth! self
end

# in config/routes.rb
Rails.application.routes.draw do
  Mumukit::Login.configure_login_routes! self
end

# in app/controllers/login_controller.rb
class LoginController < ApplicationController
  Mumukit::Login.configure_login_controller! self

  def failure
      # define your failure login handler
  end
end

# in app/controller/application_controller.rb
class ApplicationController < ActionController::Base
  Mumukit::Login.configure_controller! self

  private

  def login_settings
    # define your login settings
  end
end
```

## Customization

You can override the following methods:

* `login_methods`
* `destroy_session_user_uid!`, `save_session_user_uid!`, `current_user_uid`

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


