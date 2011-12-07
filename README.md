Tire MockClient
===============

Are you using Tire and ElasticSearch? Do you want to run your tests without booting
up ElasticSearch? Well hold on to your hats.

Instalation
-----------

In your gemfile add
gem 'tire-mock_client'

In the environments that you don't want to run ElasticSearch add:
Tire.configure do
  client Tire::Http::Client::MockClient
end

DONE!
-----

As of version 0.0.1 the search capabilities are quite limited.

### Contributions

1. Fork it.
2. Create a branch (`git checkout -b support_or_queries`)
3. Commit your changes (`git commit -am "Added OR queries"`)
4. Push to the branch (`git push origin support_or_queries`)
5. Create an [Issue][1] with a link to your branch
6. Bathe in the glory

### Contributors
Amos King

Copyright (C) 2011 Amos King amos.l.king@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.