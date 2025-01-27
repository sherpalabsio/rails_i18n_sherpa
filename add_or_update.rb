# frozen_string_literal: true

require "yaml"
require "fileutils"

class AddOrUpdate
  def self.run
    new.run
  end

  def run
    translations = read_translations

    translations.each do |entry|
      # TODO: Warn if key is missing
      key_path = entry["key"].split(".")

      %w[en nl fr].each do |locale|
        locale_file = File.join("config", "locales", "#{locale}.yml")

        current_translations = YAML.load_file(locale_file)

        current = current_translations[locale] ||= {}
        key_path[0..-2].each do |k|
          current = current[k] ||= {}
        end
        current[key_path.last] = entry[locale]

        File.open(locale_file, "w") do |file|
          file.write(current_translations.to_yaml(line_width: -1))
        end

        puts "Updated #{locale}.yml with key #{entry['key']}"
      end
    end

    system("i18n-tasks normalize") if system("command -v i18n-tasks > /dev/null")

    puts "Translation update complete!"
  end

  private

  def read_translations
    editor = ENV["EDITOR"] || "vim"
    temp_file_path = "/tmp/TRANSLATIONS.yml"

    puts "hint: Waiting for your editor to close the file..."

    system("#{editor} #{temp_file_path}")

    if File.exist?(temp_file_path)
      translations = YAML.load_file(temp_file_path)
      File.delete(temp_file_path)
      translations
    else
      exit 2
    end
  end

  def system(command)
    super
  end
end
