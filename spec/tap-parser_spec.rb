require 'tap-parser'

describe TapParser::TapParser do
  it 'from_text' do
    tap = [
      'ok 1 - retrieving servers from the database',
      '# need to ping 6 servers',
      'ok 2 - pinged diamond',
      'ok 3 - pinged ruby',
      'not ok 4 - pinged saphire',
      'ok 5 - pinged onyx',
      'not ok 6 - pinged quartz',
      'ok 7 - pinged gold',
      '1..7'
    ].join ("\n")
    parser = TapParser::TapParser.from_text(tap)
    tests = parser.tests

    expect(parser.test_count).to eq(7)
    expect(tests.length).to eq(7)
    expect(tests.map(&:description)).to eq ([
      "retrieving servers from the database",
      "pinged diamond",
      "pinged ruby",
      "pinged saphire",
      "pinged onyx",
      "pinged quartz",
      "pinged gold"
    ])

    expect(tests.map(&:passed)).to eq([
      true, true, true, false, true, false, true
    ])

    expect(tests.first.diagnostic).to eq('need to ping 6 servers')
  end

  context 'read_line' do
    let(:parser) {
      parser = TapParser::TapParser.new('')
    }

    it 'recognizes the plan' do
      parser.read_line("1..12")
      expect(parser.test_count).to eq(12)
    end

    context 'recognizes a test' do
      it 'from the status' do
        parser.read_line('ok')
        parser.read_line('not ok')

        expect(parser.tests.length).to eq(2)
        expect(parser.tests[0].passed).to be true
        expect(parser.tests[1].passed).to be false
      end

      it 'can also get the test number' do
        parser.read_line('ok 1')
        test = parser.tests.first

        expect(test.passed).to be true
        expect(test.number).to eq(1)
      end

      it 'extracts the description' do
        parser.read_line('ok 1 My test')
        parser.read_line('ok My second test')

        expect(parser.tests.map(&:description)).to eq(['My test', 'My second test'])
      end

      it 'dash at the beggining of a description is skipper' do
        parser.read_line('ok - My second test')
        expect(parser.tests.first.description).to eq('My second test')
      end

      it 'separates description and directive' do
        parser.read_line('ok 1 My test # It has a directive')

        test = parser.tests.first
        expect(test.description).to eq('My test')
        expect(test.directive).to eq('It has a directive')
      end
    end

    context 'handles diagnostic' do
      it 'and adds it to the last test' do
        parser.read_line('not ok')
        parser.read_line('# Something went wrong')

        expect(parser.tests.last.diagnostic).to eq('Something went wrong')

        parser.read_line('# but well, shit happens')
        expect(parser.tests.last.diagnostic).to eq([
          'Something went wrong',
          'but well, shit happens'
        ].join("\n"))
      end

      it 'if there is no tests, it is skipped' do
        parser.read_line('# Something went wrong')        
      end
    end
  end
end