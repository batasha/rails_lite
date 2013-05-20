require 'active_support/core_ext'
require 'webrick'
# require 'rails_lite'
require_relative 'controller_base'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html
server = WEBrick::HTTPServer.new :Port => 8080, :DocumentRoot => '/'
trap('INT') { server.shutdown }

class MyController < ControllerBase
  def go
    if @req.path == '/redirect'
      redirect_to('http://google.com')
    elsif @req.path == '/render'
      render_content(@req.query_string.split('=').last, 'text/text')
    end

    # after you have sessions going, uncomment:
#    session["count"] ||= 0
#    session["count"] += 1
#    render_content("#{session["count"]}", "text/html")

    # after you have template rendering
#    render :show
  end
end

server.mount_proc '/' do |req, res|
  res['Content-Type'] = 'text/text'
  res.body = req.path

  MyController.new(req, res).go
end

server.start