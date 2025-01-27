# frozen_string_literal: true

require "yaml"

module UserInterface
  TEMP_FILE_PATH = "/tmp/TRANSLATIONS.yml"

  def self.fetch_translations
    editor = ENV["EDITOR"] || "vim"

    puts "hint: Waiting for your editor to close the file..."

    system("#{editor} #{TEMP_FILE_PATH}")

    if File.exist?(TEMP_FILE_PATH)
      translations = YAML.load_file(TEMP_FILE_PATH)
      File.delete(TEMP_FILE_PATH)
      remove_last_console_line
      translations
    else
      exit 2
    end
  end

  def self.remove_last_console_line
    print "\e[A\e[K"
  end
end
