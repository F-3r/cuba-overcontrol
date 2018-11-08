require "minitest"
require "minitest/autorun"
require "cuba"
require "rack/test"
require "cuba/render"
require_relative "../lib/overcontrol"

include Rack::Test::Methods

def must_respond(method, path, params: {}, status:, content: nil)
  send(method, path, params)

  last_response.status.must_equal status
  last_response.body.must_equal content if content
end

class TestApp < Cuba
  include Overcontrol::Routing
  include Cuba::Render
end

class TestController < Overcontrol::Controller
  attr_accessor :id

  def action
    res.write "ok"
  end

  def index
    res.write "index"
  end
end

class UsersController < Overcontrol::Controller
  attr_accessor :id

  def index
    res.write "index"
  end

  def edit
    res.write "edit"
  end

  def update
    res.write "update"
  end

  def new
    res.write "new"
  end

  def create
    res.write "create"
  end

  def delete
    res.write "delete"
  end

  def show
    res.write "show"
  end

  def activate
    res.write "active"
  end
end
