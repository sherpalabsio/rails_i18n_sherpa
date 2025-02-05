# frozen_string_literal: true

require "yaml"
# require "fileutils"

class FindKeyByValue
  LOCALE_FILE_PATH = File.join("config", "locales", "en.yml")

  def self.run(value)
    current_translations = YAML.load_file(LOCALE_FILE_PATH)["en"]

    if value.include?("__")
      value = value
              .gsub("__", "")
              .gsub(/\s+/, " ")

      if value.include?("*")
        value = value.gsub("*", ".*")
        value = Regexp.new(value)
      end

      find_key_path_but_ignore_placeholders(current_translations, value)
    else
      if value.include?("*")
        value = value.gsub("*", ".*")
        value = Regexp.new(value)
      end

      find_key_path(current_translations, value)
    end
  end

  def self.find_key_path(nested_hash, target_value, current_path = [])
    nested_hash.each do |key, value|
      new_path = current_path + [key.to_s]

      if value.is_a?(Hash)
        result = find_key_path(value, target_value, new_path)
        return result if result
      elsif value.is_a?(String)
        value = value.gsub(%r{</?[^>]*>}, "")
        if target_value.is_a?(Regexp)
          return new_path.join(".") if value.match?(target_value)
        elsif value == target_value
          return new_path.join(".")
        end
      end
    end

    nil
  end

  def self.find_key_path_but_ignore_placeholders(nested_hash, target_value, current_path = [])
    nested_hash.each do |key, value|
      new_path = current_path + [key.to_s]

      if value.is_a?(Hash)
        result = find_key_path_but_ignore_placeholders(value, target_value, new_path)
        return result if result
      elsif value.is_a?(String)
        # Remove placeholders and extra spaces from the value
        value = value
                .gsub(/%\{.*?\}/, "")
                .gsub(/\s+/, " ")
                .gsub(%r{</?[^>]*>}, "")

        if target_value.is_a?(Regexp)
          return new_path.join(".") if value.match?(target_value)
        elsif value == target_value
          return new_path.join(".")
        end

      end
    end

    nil
  end
end
