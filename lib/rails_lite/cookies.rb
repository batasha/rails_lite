require 'json'

class Session

  def initialize(req)
    cookie = req.cookies.detect { |c| c.name == '_rails_lite_app'}
    @cookie = cookie.value.empty? ? {} : JSON.parse(cookie.value)
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, value)
    @cookie[key] = value
  end

  def store_session(response)
    response.cookies << Cookie.new('_rails_lite_app', JSON.generate(@cookie))
  end
end