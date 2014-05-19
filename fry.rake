task :test do
  install_ssh_keys
  clone_repository
  create_database_yml
  setup_database
  bundle
  test_app
end
  
def run(commands)
  commands.each do |command|
    puts "$ #{command}"
    puts = `#{command}`
    puts ''
  end
end

def setup_database
  commands = [
    "cd #{ENV['app_dir']}",
    "rake db:create RAILS_ENV=test",
    "rake db:migrate RAILS_ENV=test",
  ]

  run commands
end

def bundle
  run ["bundle install --system --without failure"]
end

def clone_repository
  run ["git clone #{ENV['clone_url']}"]
end

def install_ssh_keys
  topic 'Installing SSH keys' 

  commands = [
    "mkdir ~/.ssh",
    "echo \"#{ENV['ssh_key']}\" > ~/.ssh/id_rsa",
    "echo \"#{ENV['known_hosts']}\" > ~/.ssh/known_hosts",
    "ssh-agent -c",
    "ssh-add ~/.ssh/id_rsa",
   end
   run commands
end

# writes ERB based database.yml for Rails. The database.yml uses the DATABASE_URL from the environment during runtime.
def create_database_yml
  return unless File.directory?("#{ENV['app_dir']}/config")
  topic "Writing config/database.yml to read from DATABASE_URL"
  File.open("config/database.yml", "w") do |file|
    file.puts <<-DATABASE_YML
<%

require 'cgi'
require 'uri'

begin
uri = URI.parse(ENV["DATABASE_URL"])
rescue URI::InvalidURIError
raise "Invalid DATABASE_URL"
end

raise "No RACK_ENV or RAILS_ENV found" unless ENV["RAILS_ENV"] || ENV["RACK_ENV"]

def attribute(name, value, force_string = false)
if value
value_string =
if force_string
  '"' + value + '"'
else
  value
end
"\#{name}: \#{value_string}"
else
""
end
end

adapter = uri.scheme
adapter = "postgresql" if adapter == "postgres"

database = (uri.path || "").split("/")[1]

username = uri.user
password = uri.password

host = uri.host
port = uri.port

params = CGI.parse(uri.query || "")

%>

test:
<%= attribute "adapter",  adapter %>
<%= attribute "database", database %>
<%= attribute "username", username %>
<%= attribute "password", password, true %>
<%= attribute "host",     host %>
<%= attribute "port",     port %>

<% params.each do |key, value| %>
<%= key %>: <%= value.first %>
<% end %>
  DATABASE_YML
  end
end

def test_app
  run ["rspec spec/ --color"]
end

# display a topic message
# (denoted by ----->)
# @param [String] topic message to be displayed
def topic(message)
  puts "-----> #{message}"
end

end

