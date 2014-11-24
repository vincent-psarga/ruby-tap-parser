module TapParser
  class Test
    attr_reader :passed, :number, :description, :directive, :diagnostic

    def initialize(passed, number, description = '', directive = '', diagnostic = '')
      @passed = passed
      @number = number
      @description = description
      @directive = directive
      @diagnostic = diagnostic
    end

    def failed
      !@passed
    end

    def add_diagnostic(line)
      if @diagnostic.empty?
        @diagnostic = line
      else
        @diagnostic = "#{@diagnostic}\n#{line}"
      end
    end
  end

  class TapParser
    attr_reader :test_count, :tests

    def self.from_text(txt)
      parser = TapParser.new(txt)
      parser.read_lines()
      parser
    end

    def initialize(content)
      @content = content
      @test_count = 0
      @tests = []
    end

    def read_lines()
      @content.split("\n").each {|l| read_line(l)}
    end

    def read_line(line)
      /1\.\.(\d+)/.match(line) do |match|
        @test_count = match.captures[0].to_i
        return
      end

      /(?<status>ok|not ok)\s*(?<test_number>\d*)\s*-?\s*(?<test_desc>[^#]*)(\s*#\s*(?<test_directive>.*))?/.match(line) do |match|
        @tests << Test.new(
          match[:status] == 'ok',
          match[:test_number] ? match[:test_number].to_i : nil,
          match[:test_desc] ? match[:test_desc].strip : '',
          match[:test_directive]
        )
        return
      end

      /^\s*#?\s*(?<test_diagnostic>.*)$/.match(line) do |match|
        unless @tests.empty?
          @tests.last.add_diagnostic(match[:test_diagnostic])
        end
      end
    end
  end
end
