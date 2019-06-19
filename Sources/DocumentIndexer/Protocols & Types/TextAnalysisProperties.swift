///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import os.log

fileprivate let log = OSLog(subsystem: ModuleIdentifier,
                            category: "Text Analysis Properties")

/// Text analysis properties
/// - See More: [Text Analysis Keys](https://developer.apple.com/documentation/coreservices/search_kit/text_analysis_keys)
public struct TextAnalysisProperties {
    /// The minimum term length to index.
    /// - See More: [kSKMinTermLength](https://developer.apple.com/documentation/coreservices/kskmintermlength)
    var minTermLength: Int = 1

    /// A dictionary of term substitutions—terms that differ in their character strings but that match during a search.
    ///
    /// For example: with the substitutions dictionary `["foo": "bar"]` the indexer would replace "bar" with "foo" in the input text before indexing.
    /// - See More: [kSKSubstitutions](https://developer.apple.com/documentation/coreservices/ksksubstitutions)
    var substitutions: [String: String] = [:]

    /// The maximum number of number unique terms to index in each document.
    ///
    /// Search Kit indexes from the beginning of a document. When it has indexed the `maximumTerms` unique terms, it stops.
    /// - See More: [kSKMaximumTerms](https://developer.apple.com/documentation/coreservices/kskmaximumterms)
    var maximumTerms: Int = 0

    /// A Boolean flag indicating whether or not Search Kit should use proximity indexing.
    ///
    /// Proximity indexing is available only for inverted indexes — that is, indexes of type `IndexType.inverted`.
    /// Use proximity indexing to support phrase searching. It defaults not to add proximity information to the index.
    /// - See More: [kSKProximityIndexing](https://developer.apple.com/documentation/coreservices/kskproximityindexing)
    var proximityIndexing: Bool = false

    /// Additional valid starting-position “word” characters for indexing and querying.
    /// - See More: [kSKTermChars](https://developer.apple.com/documentation/coreservices/ksktermchars)
    var termChars: [Character] = []

    /// Additional valid starting-position “word” characters for indexing and querying.
    /// - See More: [kSKStartTermChars](https://developer.apple.com/documentation/coreservices/kskstarttermchars)
    var startTermChars: String = ""
    
    /// Additional valid last-position “word” characters for indexing and querying.
    /// - See More: [kSKEndTermChars](https://developer.apple.com/documentation/coreservices/kskendtermchars)
    var endTermChars: String = ""

    public static var `default`: TextAnalysisProperties = TextAnalysisProperties()

    /// Provides a flexible way to customize properties right in a declaration spot by way of modifying them from within the provided closure.
    /// # Example:
    /// ```
    /// let props = TextAnalysisProperties().customized {
    ///     $0.substitutions = ["foo": "bar"]
    ///     $0.minTermLength = 3
    /// }
    /// ```
    func customized(_ handler: (inout TextAnalysisProperties) -> Void) -> TextAnalysisProperties {
        var copy = self
        handler(&copy)
        return copy
    }
}

extension NSDictionary {
    convenience init(_ props: TextAnalysisProperties) {
        self.init(dictionary: [
            kSKMinTermLength!: props.minTermLength,
            kSKSubstitutions!: props.substitutions,
            kSKMaximumTerms!: props.maximumTerms,
            kSKProximityIndexing!: props.proximityIndexing,
            kSKTermChars!: props.termChars,
            kSKStartTermChars!: props.startTermChars,
            kSKEndTermChars!: props.endTermChars
        ])
    }
}
