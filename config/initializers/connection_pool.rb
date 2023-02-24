require 'connection_pool'

pool_size = ENV.fetch('DATABASE_POOL', 15).to_i
pool_timeout = ENV.fetch('DATABASE_TIMEOUT', 15).to_i

Jets.application.config.database_connection_pool = ConnectionPool.new(size: pool_size, timeout: pool_timeout) do
  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: ENV.fetch('DB_HOST_PRODUCTION'),
    database: 'backend_production',
    username: 'rails_user',
    password: ENV.fetch('DB_PASSWORD_PRODUCTION')
  )

  ActiveRecord::Base.connection
end