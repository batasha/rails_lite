class ControllerBase

  def initialize(req, res)
    @req, @res = req, res
  end

  def render_content(content, body_type)
    @res.content_type, @res.body = body_type, content
    @response_built = true
  end

  def redirect_to(url)
    @res.status = 302
    @res['Location'] = url
    @response_built = true
  end
end