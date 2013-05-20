class Route
  def initialize(opts={})
    @pattern = opts[:pattern]
    @method = opts[:method]
    @controller = opts[:controller]
    @action = opts[:action]
  end

  def matches?(req)
    req.path =~ @pattern && req.request_method.downcase.to_sym == @method
  end

  def run(req, res)
    @controller.new(req, res).invoke_action(@action)
  end
end

class Router
  def initialize
    @routes = []
  end

  def add_route(route)
    opts = {
      method: method,
      pattern: pattern,
      controller: controller_class,
      action: action_name
    }
    @routes << Route.new(opts)
  end

  [:get, :post, :put, :delete].each do |method|
    define_method(method, pattern, controller_class, action_name) do
      add_route(Route.new(opts))
    end
  end

  def match(req)
    @routes.detect { |route| route.matches?(req) }
  end

  def run(req, res)
    (route = match(req)) ? route.run || (res.status = 404)
  end

  def draw(&block)
    instance_eval(&block)
  end
end