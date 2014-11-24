ruby-tap-parser
===============

[![Build Status](https://travis-ci.org/vincent-psarga/ruby-tap-parser.svg?branch=master)](https://travis-ci.org/vincent-psarga/ruby-tap-parser)
[![Code Climate](https://codeclimate.com/github/vincent-psarga/ruby-tap-parser/badges/gpa.svg)](https://codeclimate.com/github/vincent-psarga/ruby-tap-parser)
[![Test Coverage](https://codeclimate.com/github/vincent-psarga/ruby-tap-parser/badges/coverage.svg)](https://codeclimate.com/github/vincent-psarga/ruby-tap-parser)


Gem to parse TAP (test anything protocol) output.

Sample use
----------

Simply use ``TapParser::TapParser.from_text`` to get the content read:

    require 'tap-parser'

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

And then access ``parser.test_count`` to get the number of tests described in the plan and ``parser.tests`` to get the tests result.
Each entry in the list is a ``TapParser::Test`` object and has the following properties:

 - passed: a boolean telling if the test passed
 - failed: a boolean if the test failed
 - number: the test number, if provided in the tap file
 - description: the description of the test if provided by the tap file
 - directive: the test directive if provided
 - diagnostic: the diagnostic of the test

