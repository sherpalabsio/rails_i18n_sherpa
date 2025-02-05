# frozen_string_literal: true

require "fileutils"
require_relative "../../lib/find_key_by_value"

describe FindKeyByValue do
  let(:locale_file_content) do
    <<~HEREDOC
      ---
      en:
        level_1:
          sub_level1: Initial content
    HEREDOC
  end

  before do
    locale_file = File.join("config", "locales", "en.yml")
    FileUtils.mkdir_p(File.dirname(locale_file))
    File.write(locale_file, locale_file_content)
  end

  after do
    FileUtils.rm_rf("config")
  end

  describe "finding exact match" do
    it "returns the expected key" do
      result = described_class.run("Initial content")

      expect(result).to eq("level_1.sub_level1")
    end
  end

  describe "finding partial match" do
    let(:locale_file_content) do
      <<~HEREDOC
        ---
        en:
          level_1:
            sub_level1: Initial content
      HEREDOC
    end

    it "returns the expected key" do
      result = described_class.run("Initial cont*")

      expect(result).to eq("level_1.sub_level1")
    end
  end

  describe "ignoring placeholders" do
    let(:locale_file_content) do
      <<~HEREDOC
        ---
        en:
          level_1:
            sub_level1: Before %{date} and after
      HEREDOC
    end

    it "returns the expected key" do
      result = described_class.run("Before __ and after")

      expect(result).to eq("level_1.sub_level1")
    end
  end

  describe "finding partial match and ignoring placeholders" do
    let(:locale_file_content) do
      <<~HEREDOC
        ---
        en:
          level_1:
            sub_level1: Before %{date} and after
      HEREDOC
    end

    it "returns the expected key" do
      result = described_class.run("Before __ and af*")

      expect(result).to eq("level_1.sub_level1")
    end
  end
end
