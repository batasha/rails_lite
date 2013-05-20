require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require 'uri'
require 'debugger'

module Params
  def self.parse(req, route_params)
    params = {}

    params.merge!(route_params)
    params.merge!(parse_www_encoded_form(req.body)) if req.body
    params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string

    params
  end

  def self.parse_www_encoded_form(form)
    params = {}

    key_values = URI.decode_www_form(form)
    key_values.each do |key, value|
      scope = params

      key_seq = parse_key(key)
      key_seq.each_with_index do |k, i|
        if i == key_seq.count - 1
          scope[k] = value
        else
          scope[k] ||= {}
          scope = scope[k]
        end
      end
    end
    params
  end

  def self.parse_key(key)
     match_data = /(?<head>.*)\[(?<rest>.*)\]/.match(key)
     if match_data
       parse_key(match_data["rest"]).unshift(match_data["head"])
     else
       [key]
     end
  end
end

class ControllerBase
  attr_reader :params

  def initialize(req, res, params = {})
    @req, @res = req, res
    @params = Params::parse(req, params)
  end

  def render_content(content, body_type)
    @res.content_type, @res.body = body_type, content
    session.store_session(@res)
    @response_built = true
  end

  def redirect_to(url)
    @res.status = 302
    @res['Location'] = url
    session.store_session(@res)
    @response_built = true
  end

  def session
    @session ||= Session.new(@req)
  end

  def render(file)
    view_path = self.class.to_s.underscore
    view_path.slice! "_controller"
    path = "views/#{view_path}/#{file}.html.erb"
    render_content(ERB.new(File.read(path)).result(binding), 'text/html')
  end

  def invoke_action(action_name)
    self.send(action_name)
    render(action_name) unless @response_built
  end
end