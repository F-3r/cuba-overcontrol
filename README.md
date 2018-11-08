# Overcontrol

Thin controller layer for [Cuba](github.com/soveran/cuba)

## Motivation

The idea behind Overcontrol is to provide some helpers to allow a simple and readable way to decouple logic from the routing tree.

Although we consider that a strength of Cuba, as is incredibly simple, elegant, and let's us move fast.

Usually, while a project evolves, our cuba apps grow bigger than funny, sometimes repetitive, and hard to follow.

On our team, each developer takes a different approach foat refactoring them.

The idea behind Overcontrol is to have a common go-to strategy, unobtrusive, eye-efficient and easy to test.


### Usage

Overcontrol provide 3 helpers for your Cuba app:

* `#route`: basic delegation helper (used on the next two)
* `#resource`: Rails-like Rest-like routes
* `#overcontrol`: tiny DSL to avoid repetitive route declarations

#### #route

Defines a route on your cuba app and delegates the handling of the request to the specified controller and method

```ruby
class TestApp < Cuba
  include Overcontrol::Routing

  define do
    route get, "route", to: TestController, action: :method_1
    route post, "route", to: TestController, action: :method_2
    route put, "route", to: TestController, action: :method_3
    route delete, "route", to: TestController, action: :method_4
  end
end
```

#### #resource

```ruby
class App < Cuba
  include Overcontrol::Routing

  define do
    resource "users", UsersController
  end
end
```

Will generate the following routes:

* get, "users/:id/edit"
* get, "users"
* get, "users/:id"
* put, "users/:id"
* delete, "users/:id"
* get, "users/new"
* post, "users"


If only need a subset of routes, you can specify them in the `routes` array:

```ruby
class App < Cuba
  include Overcontrol::Routing

  define do
    resource "users", UsersController, routes: [:edit :update]
  end
end
```


### DSL

The DSL will help you grouping routes that will be all delegated to the same controller

```overcontrol
class DSLApp < TestApp
  define do
    overcontrol "users", to: UsersController do |c|
      c.get "new", to: :new
      c.post root, to: :create
      c.get root, to: :index

      on :id do
        c.get "edit", to: :edit
        c.get to: :show
        c.put to: :update
        c.delete to: :delete
      end
    end
  end
end
```

## Controllers

They are just ruby classes with instance methods that handle requests and write the response.

Plus, some helpers that are shortcuts for the corresponding objects or methods of the Cuba app:

* `#app` => the cuba app itself
* `#req` => app.req
* `#res` => app.response
* `#params` => req.params
* `#headers` => req.headers
* `#session` => app.session
* `#flash` =>  app.flash
* `#redirect` => res.reditect
* `#render` =>  app.render
* `#partial` =>  app.partial
* `#view` =>  app.view

##### Additional parameters

Besides the app, req and response objects, additional parameters can be passed on invocation.
They will get assigned to instance variables on initialization.

**NOTE:** *You must declare the attr_accessors on the controller for each additional param.*


```ruby
on "params" do |id|
  route(get, "show", to: UsersController, action: :show, user: user)
end
```

## Example

A typical ReST-like controller using Sequel might look something like:

```ruby
class App < Cuba
  define do
    resource "users", UsersController
  end
end
```

```ruby
class UsersController < Overcontrol::Controller
  attr_accessor :user

  def index
    render "users/index", users: User.dataset
  end

  def new
    render "users/new", user: User.new
  end

  def create
    user = User.new.set_fields(params['user'], ['name', 'email'])

    if user.valid?
      user.save
      redirect "/users"
    else
      render "users/new", user: user
    end
  end

  def edit
    render "users/edit", user: user
  end

  def update
    user.set_fields(params['user'], ['name', 'email'])

    if user.valid?
      user.save
      redirect "/users"
    else
      render "users/edit", user: user
    end
  end

  def show
    render "users/show", user: user
  end

  def delete
    user.delete
  end
end
```
