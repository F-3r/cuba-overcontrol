require 'rack'
require 'cuba'
require 'cuba/render'
require 'tilt'

require_relative './lib/ctrl'

class UsersController < Ctrl
  attr_accessor :name

  def index
    puts "Index"
    render "users/index"
  end

  def show
    puts "show #{name.inspect}"
    res.write "show #{name.inspect}"
  end

  def edit
    puts "edit"
    res.write "edit"
  end

  def redir
    redirect "/users"
  end
end

class App < Cuba
  plugin Ctrl::Routing
  plugin Ctrl::Sugar
  plugin Cuba::Render

  define do
    name = 1234
    ctrl UsersController, path: "users" do
      get "edit", to: :edit
      get "redirect-me", to: :redir
      get ":id", to: :show, name: name
      get to: :index
    end

    ctrl UsersController do
      get "edit", to: :edit
      get "redirect-me", to: :redir
      get ":id", to: :show, name: name
      get to: :index
    end
  end
end

run App
