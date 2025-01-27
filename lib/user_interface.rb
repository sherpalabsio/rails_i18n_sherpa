# frozen_string_literal: true

require "yaml"

module UserInterface
  TEMP_FILE_PATH = "/tmp/TRANSLATIONS"

  def self.fetch_translations
    editor = ENV["EDITOR"] || "vim"

    puts "hint: Waiting for your editor to close the file..."

    system("#{editor} #{TEMP_FILE_PATH}")

    if File.exist?(TEMP_FILE_PATH)
      translations = parse_translations(File.read(TEMP_FILE_PATH))
      File.delete(TEMP_FILE_PATH)
      remove_last_console_line
      translations
    else
      exit 2
    end
  end

  def self.parse_translations(content)
    final_content = []

    content.each_line do |line|
      line.strip!
      next if line.empty?

      key, = line.split(": ", 2)
      final_content << if key == "key"
                         "- #{line}"
                       elsif key.length == 2
                         "  #{line}"
                       else
                         "    #{line}"
                       end
    end

    YAML.safe_load(final_content.join("\n"))
  end

  def self.remove_last_console_line
    print "\e[A\e[K"
  end
end
