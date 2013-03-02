# Fuse

Portable document authoring. Fuse HTML, JavaScript, CSS, images and fonts into standalone HTML files.

* Drop all your assets in a directory and hit the magic button.
* Built-in web server based on Thin for authoring your docs.
* Support for SASS and CoffeeScript.
* Sprockets-like 'require' syntax for JS and CSS dependency
* Uses uglify-js to compress JavaScript
* Simple file naming conventions for font names and CSS media types
* Transform XML documents on the fly using XSLT

## How to use Fuse

### Authoring

Put some HTML, CSS, JavaScript etc in a directory. `cd` to that directory and run:

```bash
fuse server
```

Go to `http://localhost:9460` to view your doc.

### Compiling

When you're happy, from the same directory, run:

```bash
fuse compile > my_doc.html
```

Presto.

## Command Line Options

Run `fuse` for a full list of command line options.

Some things you can do from the command line:

* Specify a port for the server
* Enable/disable asset embedding and/or compression
* Specify a source document and/or XSL stylesheet
* Specify the output HTML document's character set
* Specify an HTML title

## Early days

This gem is truly in its infancy. I'll put in what time I have available. It's also my first gem, so I welcome suggestions, pull requests etc.

## License

Released under [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). See [LICENSE](LICENSE) for details.