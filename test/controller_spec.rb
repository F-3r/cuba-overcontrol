require_relative "./helper"

describe "Overcontrol Controller" do
  describe "invoke" do
    def app
      NotDefinedAction
    end

    class NotDefinedAction < TestApp
      define do
        route get, "users", to: NotDefinedActionController, action: :any
      end
    end

    class NotDefinedActionController < Overcontrol::Controller
    end

    it "raises Error if action is not defined" do
      -> { get "/users" }.must_raise Overcontrol::Error
    end
  end
end
