# BTree
BTree implementation imported from SqueakSource

### Load it from a workspace
Open a workspace and evaluate:

    Metacello new
      repository: 'github://sebastianconcept/BTree';
      baseline: 'BTree';
      load.

### Load it from `BaselineOfYourProject`
I suggest you use your `baseline: spec` method and inside your version block code, call `self btree: spec` method consisting of:

    btree: spec
      spec
      baseline: 'BTree'
      with: [ spec repository: 'github://sebastianconcept/BTree:master/src' ]
### Source and credits
- Imported it from [SqueakSource](http://www.squeaksource.com/BTree/).
- [Avi Bryant](https://twitter.com/avibryant)
- [Adrian Lienhard](https://twitter.com/adrianlienhard)
- [Ramon Leon](https://twitter.com/ramon_leon)
- [Lukas Renggli](https://twitter.com/renggli)

