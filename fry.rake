task :test do
  commands = [
    "mkdir ~/.ssh",
    "echo \"#{ENV['ssh_key']}\" > ~/.ssh/id_rsa",
    "ssh-agent",
    "ssh-add ~/.ssh/id_rsa"
  ]

  commands.each do |command|
    puts "$ #{command}"
    puts = `#{command}`
    puts ''
  end
end

