require_relative "./helper"

describe "#route" do
  class RoutesApp < TestApp
    define do
      route get, "route", to: TestController, action: :action
      route post, "route", to: TestController, action: :action
      route put, "route", to: TestController, action: :action
      route delete, "route", to: TestController, action: :action
    end
  end

  def app
    RoutesApp
  end

  it "respond to /route with all methods" do
    must_respond(:get, "route", status: 200, content: "ok")
    must_respond(:put, "route", status: 200, content: "ok")
    must_respond(:delete, "route", status: 200, content: "ok")
    must_respond(:post, "route", status: 200, content: "ok")
  end

  describe "action" do
    class Action < TestApp
      define do
        route get, "index", to: TestController, action: :index
        route get, "not-existent", to: TestController, action: :not_existent
      end
    end

    def app
      Action
    end

    it "executes the specified action" do
      get "/index"

      last_response.body.must_equal "index"
      last_response.status.must_equal 200
    end

    it "raises Error when action does not exist" do
      -> { get "/not-existent" }.must_raise Overcontrol::Error
    end
  end

  describe "Aditional parameters" do
    class AditionalParamsController < Overcontrol::Controller
      attr_accessor :additional1, :additional2

      def index
        res.write "#{additional1} #{additional2}"
      end
    end

    class AdditionalParams < TestApp
      define do
        route(get, "index",
              to: AditionalParamsController,
              action: :index,
              additional1: 1,
              additional2: 2)
      end
    end

    def app
      AdditionalParams
    end

    it "executes the specified action" do
      get "/index"

      last_response.status.must_equal 200
      last_response.body.must_equal "1 2"
    end
  end
end

describe "#resource" do
  class ResourceApp < TestApp
    define do
      resource "users", UsersController
    end
  end

  def app
    ResourceApp
  end

  describe "With all ReST-like routes" do
    it "responds ok" do
      must_respond(:get, "/users/1/edit", status: 200, content: "edit")
      must_respond(:get, "/users", status: 200, content: "index")
      must_respond(:get, "/users/1", status: 200, content: "show")
      must_respond(:put, "/users/1", status: 200, content: "update")
      must_respond(:delete, "/users/1", status: 200, content: "delete")
      must_respond(:get, "/users/new", status: 200, content: "new")
      must_respond(:post, "/users", status: 200, content: "create")
    end
  end

  describe "a single route" do
    class ResourceApp1 < TestApp
      define do
        resource "users", UsersController, routes: [:edit]
      end
    end

    def app
      ResourceApp1
    end

    it "responds ok" do
      must_respond(:get, "/users/1/edit", status: 200, content: "edit")
      # not founds
      must_respond(:get, "/users", status: 404)
      must_respond(:get, "/users/1", status: 404)
      must_respond(:put, "/users/1", status: 404)
      must_respond(:delete, "/users/1", status: 404)
      must_respond(:get, "/users/new", status: 404)
      must_respond(:post, "/users", status: 404)
    end
  end

  describe "Only edit and update" do
    class ResourceApp2 < TestApp
      define do
        resource "users", UsersController, routes: [:edit, :update]
      end
    end

    def app
      ResourceApp2
    end

    it "responds ok" do
      must_respond(:put, "/users/1", status: 200, content: "update")
      must_respond(:get, "/users/1/edit", status: 200, content: "edit")
      # not founds
      must_respond(:get, "/users", status: 404)
      must_respond(:get, "/users/1", status: 404)
      must_respond(:delete, "/users/1", status: 404)
      must_respond(:get, "/users/new", status: 404)
      must_respond(:post, "/users", status: 404)
    end
  end

  describe "Only show and index routes" do
    class ResourceApp3 < TestApp
      define do
        resource "users", UsersController, routes: [:show, :index]
      end
    end

    def app
      ResourceApp3
    end

    it "responds ok" do
      must_respond(:get, "/users", status: 200, content: "index")
      must_respond(:get, "/users/1", status: 200, content: "show")
      # "new" is matched against :id as the `new` route is not defined
      must_respond(:get, "/users/new", status: 200)
      # not founds
      must_respond(:put, "/users/1", status: 404)
      must_respond(:get, "/users/1/edit", status: 404)
      must_respond(:post, "/users", status: 404)
      must_respond(:delete, "/users/1", status: 404)
    end
  end

  describe "Only new and create routes" do
    class ResourceApp4 < TestApp
      define do
        resource "users", UsersController, routes: [:new, :create]
      end
    end

    def app
      ResourceApp4
    end

    it "responds ok" do
      must_respond(:get, "/users/new", status: 200, content: "new")
      must_respond(:post, "/users", status: 200, content: "create")
      # not founds
      must_respond(:get, "/users/1/edit", status: 404)
      must_respond(:put, "/users/1", status: 404)
      must_respond(:get, "/users/1", status: 404)
      must_respond(:get, "/users", status: 404)
      must_respond(:delete, "/users/1", status: 404)
    end
  end

  describe "Only new and create routes" do
    class ResourceApp5 < TestApp
      define do
        resource "users", UsersController, routes: [:index, :delete]
      end
    end

    def app
      ResourceApp5
    end


    it "responds ok" do
      must_respond(:get, "/users", status: 200, content: "index")
      must_respond(:delete, "/users/1", status: 200, content: "delete")
      # not founds
      must_respond(:get, "/users/new", status: 404)
      must_respond(:post, "/users", status: 404)
      must_respond(:get, "/users/1/edit", status: 404)
      must_respond(:put, "/users/1", status: 404)
      must_respond(:get, "/users/1", status: 404)
    end
  end
end
