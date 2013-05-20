require 'active_support/core_ext/object/try'
require 'active_support/inflector'

class ControllerBase

  def initialize(req, res)
    @req, @res = req, res
  end

  def render_content(content, body_type)
    @res.content_type, @res.body = body_type, content
    @session.store_session
    @response_built = true
  end

  def redirect_to(url)
    @res.status = 302
    @res['Location'] = url
    @session.store_session
    @response_built = true
  end

  def session
    @session ||= Session.new(@req)
  end

  def render(file)
    view_path = self.class.underscore
    view_path.strip! "_controller"
    path = "/views/#{view_path}/#{file}.html.erb"
    ERB.new(File.read(path)).result(binding)
  end
end