# frozen_string_literal: true

require "./add_or_update"

describe AddOrUpdate do
  let(:translation_file_content) do
    <<~HEREDOC
      - key: test.key
        en: Copy en
        nl: Copy nl
        fr: Copy fr
    HEREDOC
  end

  let(:initial_locale_file_content) do
    <<~HEREDOC
      ---
      {locale}:
        level_1:
          sub_level1: Initial content
    HEREDOC
  end

  let(:en_local_file_content) do
    File.read(File.join("config", "locales", "en.yml"))
  end

  before do
    stub_const("AddOrUpdate::SUPPORTED_LOCALES", %w[en fr])

    AddOrUpdate::SUPPORTED_LOCALES.each do |locale|
      locale_file = File.join("config", "locales", "#{locale}.yml")
      content = initial_locale_file_content.gsub("{locale}", locale)
      FileUtils.mkdir_p(File.dirname(locale_file))
      File.write(locale_file, content)
    end
  end

  after do
    FileUtils.rm_rf("config")
  end

  it "adds a new translation key" do
    allow_any_instance_of(AddOrUpdate).to receive(:system) do |_, command|
      File.write("/tmp/TRANSLATIONS.yml", translation_file_content) if command.include?("/tmp/TRANSLATIONS.yml")
    end

    described_class.run

    expect(File).not_to exist("/tmp/TRANSLATIONS.yml")

    expected_content = <<~HEREDOC
      ---
      en:
        level_1:
          sub_level1: Initial content
        test:
          key: Copy en
    HEREDOC

    expect(en_local_file_content).to eq(expected_content)
  end
end
