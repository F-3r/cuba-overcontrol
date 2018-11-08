module Overcontrol
  class Error < StandardError; end

  module Routing
    def route(*matchers, to:, action:, **args)
      on(*matchers) { to.new(self, args).call(action) }
    end

    def overcontrol(path, to:,  &block)
      DSL.new(to, path, self).evaluate(&block)
    end

    def resource(path, controller, routes: [:index, :show, :edit, :update, :new, :create, :delete])
      on path do
        route get, /new\z/, to: controller, action: :new if routes.include? :new
        route get, root, to: controller, action: :index if routes.include? :index
        route post, root, to: controller, action: :create if routes.include? :create

        if [:show, :edit, :update, :delete].any? { |r| routes.include? r }
          on :id do |id|
            route get, /edit\z/, to: controller, action: :edit, id: id if routes.include? :edit
            on root do
              route get, to: controller, action: :show, id: id if routes.include? :show
              route put, to: controller, action: :update, id: id if routes.include? :update
              route delete, to: controller, action: :delete, id: id if routes.include? :delete
            end
          end
        end
      end
    end
  end


  class DSL
    attr_reader :app, :base_path, :controller

    def initialize(controller, base_path, app)
      @base_path = base_path
      @controller = controller
      @app = app
    end

    def evaluate
      if base_path.empty?
        yield self
      else
        app.send(:on, base_path, &proc { yield self })
      end
    end

    %i[get post put patch delete].each do |method|
      define_method method do |*matchers, to:, **args|
        define_route(method, to, *matchers, **args)
      end
    end

    def define_route(method, action, *matchers, **args)
      app.send(:route, app.send(method), *matchers, to: controller, action: action, **args)
    end
  end

  class Controller
    def initialize(app, args = {})
      @app = app
      args.each {|k,v| send "#{k}=", v }
    end

    def call(action)
      if respond_to? action
        send action
      else
        raise Error, "#{action} not defined on controller #{self.class.name}"
      end
    end

    private

    def app
      @app
    end

    def res
      app.res
    end

    def req
      app.req
    end

    def params
      req.params
    end

    def session
      app.session
    end

    def flash
      app.flash
    end

    def redirect(to)
      res.redirect to
    end

    def render(*args)
      app.render *args
    end

    def partial(*args)
      app.partial *args
    end

    def view(*args)
      app.view *args
    end
  end
end
