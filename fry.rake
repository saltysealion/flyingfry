task :test do
  commands = [
    "mkdir ~/.ssh",
    "echo \"#{ENV['ssh_key']}\" > ~/.ssh/id_rsa",
    "echo \"#{ENV['known_hosts']}\" > ~/.ssh/known_hosts",
    "ssh-agent -c",
    "ssh-add ~/.ssh/id_rsa",
    "git clone #{ENV['clone_url']}",
  ]

  commands.each do |command|
    puts "$ #{command}"
    puts = `#{command}`
    puts ''
  end
end

