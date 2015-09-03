require 'sinatra'

# Require all presenters and decorators
%w(decorators presenters).each do |dir|
  Dir[File.expand_path("../#{dir}/*.rb", __FILE__)].each { |f| require f }
end

module Agilizer
  module Client
    class App < Sinatra::Base
      set :views, settings.root + '/templates'

      helpers do

        def navigation_items
          [
            { link: '',        title: 'Dashboard' },
            { link: 'sprints', title: 'Sprints' }
          ]
        end

        # Calls the `::present` method on the presenter represented
        # by the specified module name.
        #
        # @param module_name [String] module name of Presenter
        #   (e.g. :Time will use Presenters::Time)
        # @param args [...] args to initialize the presenter with
        def present(module_name, *args)
          "Agilizer::Client::Presenters::#{module_name}".constantize.present(*args)
        end

        def decorate(module_name, object)
          "Agilizer::Client::Decorators::#{module_name}".constantize.new(object)
        end
      end

      get '/' do
        erb :home
      end

      get '/issues' do
        @applied_filter = params[:filter] || {}
        @available_filter = Issue.available_filter
        @issues = Issue.with_filter(@applied_filter)

        erb :'issues/index'
      end

      # Display the sprint names in the left sidebar and
      # display a general sprint dashboard on the home page.
      #
      # TODO move current links to the navigation bar
      get '/sprints' do
        @sprints = IssueAnalysis::Sprints.names
        erb :'sprints/index'
      end

      # Display detailed information on the selected sprint:
      #   - issues, with estimate at sprint start, end and now,
      #     timespent during the sprint, developer and reviewer,
      #     status of the issue;
      #   - statistics on the issues of the sprint:
      #     - total time estimate of issues per developer and per reviewer,
      #     - total time estimate of issues at sprint start, end and now.
      get '/sprints/:sprint_name' do
        @sprint_name = params[:sprint_name]
        @sprints = IssueAnalysis::Sprints.names
        @applied_filter = params[:filter] || {}
        @applied_filter.merge! sprint: { name: params[:sprint_name] }
        @issues = Issue.with_filter(@applied_filter)
        erb :'sprints/show'
      end

      get '/assets/*' do
        asset_path = params[:splat].first
      end
    end
  end
end
