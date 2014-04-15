require 'cgi'
require 'uri'
require 'yaml'
require 'json'
require 'net/http'
require 'fileutils'

require 'ssh_bro'

module SSHBro
  class CLI
    CLIENT_ID     = '537798680864-nmntkirifcaso227mu8svaonjoo3q5i9.apps.googleusercontent.com'
    CLIENT_SECRET = '1VSrX4z1f0gM_KR9Y4oQSoke'

    def run
      creds_path = File.join(File.expand_path('~'), '.ssh', '.sshbro.yml')

      begin
        creds = YAML.load_file(creds_path)
        refresh_token = creds['refresh_token']
        doc_id = creds['doc_id']
        STDERR.puts "Loading credentials from #{creds_path}"
      rescue Errno::ENOENT
      end

      if refresh_token
        uri = URI('https://accounts.google.com/o/oauth2/token')
        res = Net::HTTP.post_form(uri, refresh_token:  refresh_token,
                                       client_id:      CLIENT_ID,
                                       client_secret:  CLIENT_SECRET,
                                       grant_type:     'refresh_token')

        access_token = JSON.parse(res.body)['access_token']
      else
        token = GoogleDocSeed.get_access_token(CLIENT_ID, CLIENT_SECRET)
        refresh_token = token['refresh_token']
        access_token = token['access_token']
        save = true
      end

      unless doc_id
        STDERR.puts 'Please enter the Google Spreadsheet URL: '
        doc_url = STDIN.gets.chomp
        doc_id = CGI.parse(URI.parse(doc_url).query)['key'].first
        save = true
      end

      if save
        STDERR.puts "Okay to save your refresh to #{creds_path}? (y\\N)"
        if gets.chomp.yaml_truthy?
          File.write(creds_path, {
            'refresh_token' => refresh_token, 'doc_id' => doc_id
          }.to_yaml)
        end
      end

      retriever = Retriever.new(access_token)
      retriever.retrieve(doc_id)

      STDERR.puts "Select an output format"
      STDERR.puts "1: SSH Config"
      STDERR.puts "2: Ansible Hosts"
      STDERR.puts "3: YAML"

      hosts_string = case STDIN.gets.chomp
      when "1" then retriever.to_ssh_hosts
      when "2" then retriever.to_ansible_hosts
      when "3" then retriever.to_yaml
      else raise "Invalid selection"
      end

      

      STDERR.puts "\n\n"

      STDOUT.puts hosts_string
    end
  end
end
