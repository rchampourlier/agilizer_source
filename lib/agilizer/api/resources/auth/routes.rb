require 'agilizer/api'

module Agilizer
  class API
    desc <<-END
    END
    post '/auth' do
      if params[:username] == 'admin' && params[:password] == 'admin'
        { success: true, token: 'admin_admin' }
      else
        { success: false, ms: 'username or password is incorrect' }
      end
    end

    get '/profile' do
      {}
    end
  end
end
