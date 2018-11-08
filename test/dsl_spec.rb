require_relative "./helper"

describe "DSL" do
  def app
    DSLApp
  end

  class DSLApp < TestApp
    define do
      overcontrol "users", to: UsersController do |c|
        c.get "new", to: :new
        c.post root, param(:user), to: :create
        c.get root, to: :index
        c.post "activate/:id", true, param(:user), to: :activate

        on :id do
          c.get "edit", to: :edit
          c.get to: :show
          c.put param(:user), to: :update
          c.delete to: :delete
        end
      end
    end
  end

  describe "With all routes" do
    it "responds ok" do
      must_respond(:get, "/users/1/edit", status: 200, content: "edit")
      must_respond(:get, "/users", status: 200, content: "index")
      must_respond(:get, "/users/1", status: 200, content: "show")
      must_respond(:put, "/users/1", params: { user: { name: 1 } }, status: 200, content: "update")
      must_respond(:delete, "/users/1", status: 200, content: "delete")
      must_respond(:get, "/users/new", status: 200, content: "new")
      must_respond(:post, "/users", params: { user: { name: 1 } }, status: 200, content: "create")
      must_respond(:post, "/users/activate/1", params: { user: { name: "test" } }, status: 200, content: "active")
    end
  end
end
