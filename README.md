Rails Edition (2015)
-------------

New in 2015 - The Rails edition of this app is now in http://github.com/virgild/jibjob-rails.

JibJob
------
http://codaset.com/virgil/jibjob


JibJob is an online resume document generator . It is a simple service that 
lets you compose your resumes using plain text and generate a PDF file or 
a formatted text version. It uses the Sinatra micro web framework and written
in Ruby. 


Developer Notes
---------------

The code is still in cleanup stage and has the following limitations:

* The data migration code is for MySQL only, although there is no MySQL specific SQL in the DataMapper models. Still waiting for dm-migrations to stabilize a bit.
* Lots of untested/uncovered code--mostly in the controllers methods


LICENSE
-------

JibJob, Copyright (c) 2009 Virgil Dimaguila

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
