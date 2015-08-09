require 'sinatra'

module Agilizer
  module Client
    class App < Sinatra::Base
      set :views, settings.root + '/templates'

      helpers do

        def navbar_items
          [
            { link: '',        title: 'Dashboard' },
            { link: 'issues',  title: 'Issues '}
          ]
        end

        # Returns an initialized presenter whose class is determined
        # by the passed reference. The presenter is initialized with
        # the specified args.
        #
        # @param reference [String] filename of the presenter (equivalent to
        #   the underscored class name)
        # @param args [...] args to initialize the presenter with
        def presenter(reference, *args)
          require File.expand_path("../presenters/#{reference}", __FILE__)
          "Agilizer::Client::Presenters::#{reference.camelize}".constantize.new(*args)
        end
      end

      get '/' do
        erb :home
      end

      get '/issues' do
        @applied_filter = params[:filter] || {}
        @available_filter = Issue.available_filter
        @issues = Issue.with_filter(@applied_filter)
        @statistics = IssueAnalysis::Statistics.calculate(@issues)
        erb :'issues/index'
      end

      get '/assets/*' do
        asset_path = params[:splat].first
      end
    end
  end
end
