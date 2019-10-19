<p align="center">
    <img src="https://img.shields.io/badge/Swift-4.2-orange" alt="Swift" />
    <img src="https://img.shields.io/badge/platform-osx-orange" alt="Platform" />
    <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-orange" alt="SPM" />
    <img src="https://img.shields.io/badge/pod-compatible-orange" alt="CocoaPods" />
    <a href="https://github.com/SergeBouts/DocumentIndexer/blob/master/LICENSE">
        <img src="https://img.shields.io/badge/licence-MIT-orange" alt="License" />
    </a>
</p>

# Document Indexer

A convenient *Swifty* wrapper for *Apple's Search Kit*.

*Search Kit* is *Apple*'s content indexing and searching solution which is widely used in *OS X*, for example in *System Preferences*, *Address Book*, *Help Viewer*, *Xcode*, *Mail* and even *Spotlight* is built on top of it. *Search Kit* features:

- Fast indexing and asynchronous searching
- Google-like query syntax, including phrase-based, prefix/suffix/substring, and Boolean searching
- Text summarization
- Control over index characteristics, like minimum term length, synonyms, and substitutions
- Flexible management of document hierarchies and indexes
- Unicode support
- Relevance ranking and statistical analysis of documents
- Thread-safe

The goal of **Document Indexer** is to simplify work with *Core Foundation*-based *Search Kit* in *Swift* by making it more *Swift*-friendly. It provides:

- In-memory (for lightning-fast search) and on-disk (for persistent storage) thread-safe text document indexers with all the functionality provided by *Apple's Search Kit*
- Auto-flushing capability, etc

 ## Usage

### Creating an in-memory document index

```swift
import DocumentIndexer
...
// Create an inverted index (by default)
let indexer = InMemoryDocumentIndexer()
// Or create an inverted vector index, for example
let vectorIndexer = InMemoryDocumentIndexer(indexType: .invertedVector)
```
For the the details on search indexes, refer to [Search Basics](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_basics/searchKit_basics.html).

### Creating a persistent (on-disk) document index

```swift
import DocumentIndexer
...
let fileURL = "file:/INDEX_STORAGE_PATH"
// Create an inverted index (by default)
let indexer = PersistentDocumentIndexer(creatingAtURL: fileURL)
// Or create an inverted vector index, for example
let vectorIndexer = PersistentDocumentIndexer(creatingAtURL: fileURL, indexType: .invertedVector)
```

For the details on search indexes, refer to [Search Basics](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_basics/searchKit_basics.html).


### Opening a persistent (on-disk) document index that already exists

```swift
import DocumentIndexer
...
let fileURL = "file:/INDEX_STORAGE_PATH"
let indexer = PersistentDocumentIndexer(openingAtURL: fileURL)
```

### Creating a document URL object

```swift
import DocumentIndexer
...
let documentURLObject = DocumentURL(URL(string: ":document-name")!)! // where "document-name" is an arbitrary document identifying string adhering to the URI syntax
```
Note: `DocumentURL` is simply a wrapper around [SKDocument](https://developer.apple.com/documentation/coreservices/skdocument).

### Indexing a document explicitly

```swift
import DocumentIndexer
...
let documentURLObject = DocumentURL(URL(string: ":document-name")!)!
let documentTextualContent = "Lorem ipsum ..."
try indexer.indexDocument(at: documentURLObject, withText: documentTextualContent)
// Commit all in-memory changes to backing store
try indexer.flush() 
```

The last operation is an explicit flushing of the state to backing store - the actual flushing strategy depends on the implementation (see [Index flushing](#Index-flushing)).

### Indexing a file document

```swift
import DocumentIndexer
...
let textContentFileURL = URL(string: "file:/FILE_PATH")!
let fileURLObject = FileDocumentURL(textContentFileURL)!
try indexer.indexFileDocument(at: fileURLObject)
// Commit all in-memory changes to backing store
try indexer.flush() 
```

The last operation is an explicit flushing of the state to backing store - the actual flushing strategy depends on the implementation (see [Index flushing](#Index-flushing)).

### Removing a document from an index

```swift
import DocumentIndexer
...
let documentURLObject = DocumentURL(URL(string: ":document-name")!)!
try indexer.removeDocument(at: documentURLObject)
```

### Searching

The **Document Indexer** provides two ways of searching: sequence-based search and completion-based search. 
A good practice is not to present all the search results at once, but rather provide them gradually, in blocks. Thus Search Kit's search is block-oriented.

**Document Indexer** allows specifying the number of hits in a block with the `hitsAtATime` parameter. Other than that you can also provide the search options and the maximum search time. 

The hits (or hit objects) are represented by the `SearchHit` struct, which contains a document URL object associated with the original document, `documentURL`, and a not normalized hit relevance score, `score`.

For query format description see [Search Kit - Queries](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_concepts/searchKit_concepts.html#//apple_ref/doc/uid/TP40002844-BABIHICA).

#### Sequence-based search

```swift
import DocumentIndexer
...
for hits in indexer.makeSearch(for: "foo bar", hitsAtATime: 100) {
    hits.forEach { print("\($0.documentURL) \($0.score)") }
}
```

The `makeSearch` method returns a searcher sequence that provides search result hits in `hitsAtATime`-sized blocks of hit objects for the given `query` string. 
If you don't need the search results broken into blocks, the following one-liner demonstrates getting a search result's hits all at once:

```swift
let allHits = indexer.makeSearch(for: "foo bar").reduce([], +)
```

The searcher sequence that the `makeSearch` method returns does support laziness and if used in a 'lazy' context it performs the actual searching for the next hits block only on demand.

#### Completion-based search

```swift
import DocumentIndexer
...
indexer.search(for: "foo bar", hitsAtATime: 100) { hits, hasMore, shouldStop in
    hits.forEach { print("\($0.documentURL) \($0.score)") }
}
```
The search completion closure receives the results in the form of a hit object array. 

`Search Kit` is thread-safe and was developed with asynchronous work scenarios in mind, so wrapping the search query with a *DispatchQueue* block is a way to go.

## Text analysis properties

Currently, there are available 8 text analysis properties, affecting such aspects of indexing as phrase-based searches support, index size, search efficiency. These properties are provided to the index at the time of creation. **Document Indexer** keeps these properties grouped in the `TextAnalysisProperties` struct. The properties struct provides a flexible way to customize its properties right in the declaration spot by way of modifying them from within the closure handler provided by the `customized` method. For example:

```swift
import DocumentIndexer
...
let indexer = InMemoryDocumentIndexer(textAnalysisProperties: TextAnalysisProperties().customized({
    $0.minTermLength = 4
  	$0.substitutions = ["bar": "the"]
}))
```

**Document Indexer** mirrors the Search Kit's text analysis properties described in [Text Analisys Keys](https://developer.apple.com/documentation/coreservices/search_kit/text_analysis_keys).

## Index flushing

The index becomes stale when the application updates it by indexing or removing a document. A search on an index in such a state won’t have access to the nonflushed updates. Calling the method `flush()` makes the state consistent, by flushing index-update information and committing index caches to backing store. 

**Document Indexer** provides the option to enable *automatic* flushing either *before each search* or *after each index update*. The following code illustrates how to turn on the automatic flushing before each search:

```swift
import DocumentIndexer
...
let indexer = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch)
```
For a persistent (on-disk) document indexer, the `autoflushStrategy` has to be specified for *both* creating and opening.
The flushing is not a cheap operation so it's not recommended to perform on the main thread. The handling of flushing should be done carefully, and which way is apropriate depends on the implementation.

See Also: [SKIndexFlush](https://developer.apple.com/documentation/coreservices/1450667-skindexflush)

## Index compacting

The index can develop fragmentation (that is, it can become bloated with unused data) as documents are indexed and removed. Compacting an index is done with the method `compact()`. Because this operation typically takes significant time, it should only be done when an index is significantly fragmented.

**Document Indexer** provides a property `uncompactedDocuments` which does its best to tell how many uncompacted documents the index contains. It does its job by tracking fragmantation state and this involves an additional overhead from the user.  To track fragmantation state there should be maintained a fragmentation state preservation. It's optional and delegated to a fragmentation state preserver implemented by the user. The `uncompactedDocuments`property returns a non-`nil` value only if this delegate is provided.

The fragmentation state preservation is done by the user's implemented preserver, which conforms to the protocol `FragmentationStatePreserver`. Its instance is provided at the time of creating (for an on-disk indexer - both creating and opening) the document indexer. The preserver's only responsibility is to persist the provided piece of information in any way by being able of storing and restoring it at request.

Here's an example of how fragmentation state preserver can be implementated and then provided to a document indexer:
```swift
import DocumentIndexer
...
struct IndexerFragmentationStatePreserver: FragmentationStatePreserver {
    func preserve(_ state: FragmentationState) {
        UserDefaults.standard.setValue(state.maximumDocumentID, forKey: "maximumDocumentID")
        UserDefaults.standard.setValue(state.documentCount, forKey: "documentCount")
    }
    func restore() -> FragmentationState {
        guard let maximumDocumentID = UserDefaults.standard.object(forKey: "maximumDocumentID") as? Int,
              let documentCount = UserDefaults.standard.object(forKey: "documentCount") as? Int
        else { preconditionFailure() }
        
        return (maximumDocumentID: maximumDocumentID,
                documentCount: documentCount)
    }
}
let statePreserver = IndexerFragmentationStatePreserver()
let indexer = InMemoryDocumentIndexer(fragmentationStatePreserver: statePreserver)
```

Now that the fragmentation state preservation is implemented, it is can be used for compacting like so:
```swift
import DocumentIndexer
...
let uncompactedDocumentsAllowance = 50
if indexer.uncompactedDocuments! > uncompactedDocumentsAllowance {
    DispatchQueue.global().async {
        try indexer.compact()
    }
}
```

Note: in case of a persistent document indexer the fragmentation state preserver must be specified to both creating and opening initializers.

## Installation

### Swift Package as dependency in Xcode 11+

1. Go to "File" -> "Swift Packages" -> "Add Package Dependency"
2. Paste Document Indexer repository URL into the search field:

`https://github.com/SergeBouts/DocumentIndexer.git`

3. Click "Next"

4. Ensure that the "Rules" field is set to something like this: "Version: Up To Next Major: 1.1.0"

5. Click "Next" to finish

For more info, check out [here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### CocoaPods

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
platform :osx, '10.12'

target 'YOUR-TARGET' do
  use_frameworks!
  pod 'DocumentIndexer', :git => 'https://github.com/SergeBouts/DocumentIndexer.git'
end
```

Then run `pod install`.

See more [CocoaPods](http://cocoapods.org).

## License

This project is licensed under the MIT license.

## Resources
- [Search Basics](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_basics/searchKit_basics.html)
- [Search Kit Programming Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html)
- [Search Kit Concepts](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_concepts/searchKit_concepts.html)
- [Search Kit Reference](https://developer.apple.com/documentation/coreservices/search_kit)