# frozen_string_literal: true

require "yaml"
require "fileutils"

require "./lib/user_interface"

class AddOrUpdate
  SUPPORTED_LOCALES = %w[en nl fr].freeze

  def self.run
    new.run
  end

  def run
    UserInterface.fetch_translations.each do |entry|
      # TODO: Warn if key is missing
      key_path = entry["key"].split(".")

      SUPPORTED_LOCALES.each do |locale|
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
      end
    end

    system("i18n-tasks normalize") if system("command -v i18n-tasks > /dev/null")
  end
end
