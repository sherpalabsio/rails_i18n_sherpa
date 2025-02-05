# frozen_string_literal: true

module UserInterface
  TEMP_FILE_PATH = "/tmp/TRANSLATIONS"
  SUPPORTED_LOCALES = %w[en nl fr].freeze
  SUPPORTED_LOCALE_PREFIXES = SUPPORTED_LOCALES.map { |locale| "#{locale}:" }

  def self.fetch_translations
    editor = ENV["EDITOR"] || "vim"

    puts "hint: Waiting for your editor to close the file..." if ENV["RUBY_ENV"] != "test"

    system("#{editor} #{TEMP_FILE_PATH}")

    return unless File.exist?(TEMP_FILE_PATH)

    translations = parse_user_input(File.read(TEMP_FILE_PATH))
    File.delete(TEMP_FILE_PATH)
    remove_last_console_line if ENV["RUBY_ENV"] != "test"
    translations
  end

  def self.parse_user_input(content)
    final_content = []

    translation_block = nil
    locale_block = nil

    content.each_line do |line|
      # Translation block starts
      if line.start_with?("key:")
        final_content << translation_block if translation_block
        translation_block = {}
        translation_block["key"] = line.split(":").last.strip
        next
      end

      # Locale block starts?
      first_three_chars = line[0..2]
      if SUPPORTED_LOCALE_PREFIXES.include?(first_three_chars)
        translation_block[locale_block[:locale]] = locale_block[:value] if locale_block

        locale, value = line.split(":", 2)
        locale_block = {}
        locale_block[:locale] = locale
        locale_block[:value] = value.strip if value.strip.length.positive?
        next
      end

      # Locale block continues if it's a multiline value
      if locale_block.key?(:value)
        locale_block[:value] += "\n#{line.strip}"
      else
        locale_block[:value] = line.strip
      end
    end

    translation_block[locale_block[:locale]] = locale_block[:value] if locale_block
    final_content << translation_block if translation_block
  end

  def self.remove_last_console_line
    print "\e[A\e[K"
  end
end
