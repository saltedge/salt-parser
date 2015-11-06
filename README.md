### Salt Parser
[![Build Status](https://travis-ci.org/saltedge/salt-parser.svg)](https://travis-ci.org/saltedge/salt-parser)

Library for parsing OFX, QIF and SWIFT formats.

### Install

```ruby
gem install salt-parser
```

### Examples:
```ruby
require 'salt-parser'
require 'pp'

ofx = SaltParser::Ofx::Builder.new("spec/ofx/fixtures/v102.ofx").parser

account = ofx.accounts.first
pp "OFX account", account.to_hash

transaction = account.transactions.first
pp "OFX transaction", transaction.to_hash

###Other examples
qif = SaltParser::Qif::Builder.new("spec/qif/fixtures/bank_account.qif", "%d/%m/%Y").parser
pp "QIF account", qif.accounts.first.to_hash

swift = SaltParser::Swift::Builder.new("spec/swift/fixtures/sepa_mt9401.txt").parser
pp "SWIFT account", swift.accounts.first.to_hash
```

### Credits

Special thanks to:

- @annacruz [ofx](https://github.com/annacruz/ofx)
- @jemmyw [qif](https://github.com/jemmyw/Qif)
- @betterplace [swift](https://github.com/betterplace/mt940_parser)


### License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
