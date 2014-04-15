require 'csv'

require 'google_doc_seed'

require "ssh_bro/version"

class String
  def yaml_truthy?
    ['y', 'yes', 'true'].include?(self.downcase)
  end

  def yaml_falsey?
    ['n', 'no', 'false'].include?(self.downcase)
  end

  def to_yaml_boolean
    if self.yaml_truthy?
      return true
    elsif self.yaml_falsey?
      return false
    else
      self
    end
  end
end

module SSHBro
  class Retriever
    def initialize(token)
      @seeder = GoogleDocSeed.new(token)
    end

    def retrieve(doc_id)
      @csv = CSV.parse(@seeder.to_csv_string(doc_id), {
        headers: true,
        header_converters: :symbol,
        converters: [
          -> (f) { f.respond_to?(:empty?) && f.empty? ? nil : f },
          -> (f) { f.respond_to?(:gsub) ? f.gsub(/\s+$/, '') : f },
          -> (f) { f.respond_to?(:to_yaml_boolean) ? f.to_yaml_boolean : f },
          :all
        ]
      }).map(&:to_hash)
        .reject { |h| h[:aliases].nil? || h[:aliases].empty? || h[:use] != true }
    end

    def to_ssh_hosts
      # TODO: validate
      hosts = @csv.map { |h| h.merge(text: apply_ssh_template(h)) }
      groups = hosts.group_by { |h| [h[:provider], h[:owner]].join(" - ") }

      groups.map do |group_name, group|
        header = ('#' * 45) + "\n# #{group_name}\n" + ('#' * 45) + "\n\n"
        body = group.map { |h| h[:text] }.join("\n\n")
        header + body
      end.join("\n\n")
    end

    def apply_ssh_template(h)
      lines = [ "Host #{h[:aliases]}",
                "Hostname #{h[:hostname]}",
                "User #{h[:user]}",
                "RemoteForward 52698 localhost:52698" ].join("\n  ")


      lines.prepend("# #{h[:comment]}\n\n") if h[:comment]

      lines
    end

    def to_ansible_hosts
      hosts = @csv.map { |h| h.merge(text: apply_ansible_template(h)) }
      groups = hosts.group_by do |h| 
        "; " + [h[:provider], h[:owner]].join(" - ") + "\n[#{h[:group]}]\n"
      end

      groups.map do |group_name, group|
        body = group.map { |h| h[:text] }.join("\n")
        group_name + body
      end.join("\n\n")
    end

    def apply_ansible_template(h)
      words = [ h[:aliases].split(' ').first,
                "ansible_ssh_host=#{h[:hostname]}",
                "ansible_ssh_user=#{h[:user]}" ]
      words.join(" ")
    end

    def to_yaml
      @csv.map { |h| h.reduce({}) { |memo,(k,v)| memo.merge(k.to_s => v) } }.to_yaml
    end
  end
end
