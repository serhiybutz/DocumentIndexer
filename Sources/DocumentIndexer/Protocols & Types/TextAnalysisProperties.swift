///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import os.log

fileprivate let log = OSLog(subsystem: ModuleIdentifier,
                            category: "Text Analysis Properties")

/// A stopwords provider.
public enum Stopwords {
    /// Opt in to automatically determining the user's preferred language, otherwise the system one and establishing the ISO stopwords for that language. Optionally, with the associated value `extraStopwords` specify an additional explicit stopwords list.
    case auto(extraStopwords: [String]? = nil)
    /// Opt in to specifying custom stopwords either by way of specifying a custom language (with the associated value `isoLanguageCode`) establishing the ISO stopwords for that language or by specifying an additional explicit stopwords list with the associated value `stopwords`, or both.
    case custom(isoLanguageCode: String? = nil, stopwords: [String]? = nil)
    /// Opt out of using stopwords at all.
    case none
    
    /// The actual stopwords list.
    public var actualStopwords: [String] {
        var result: [String] = []
        switch self {
        case .auto(let extraStopwords):
            guard let languageTag = Locale.preferredLanguages.first ?? NSLocale.autoupdatingCurrent.languageCode,
                  let isoLanguageCodeStr = languageTag.components(separatedBy: "-").first
            else {
                os_log("Could determine neither user nor system language", log: log, type: .error)
                break
            }
            guard let isoLanguageCode = ISO639LanguageCode.byStrCode(isoLanguageCodeStr),
                  let stopwords = StopwordsCollection.shared.stopwordsByLanguage(isoLanguageCode)
            else {
                os_log("Invalid language code \"%s\"", log: log, type: .error, isoLanguageCodeStr)
                break
            }
            result = stopwords
            if let extraStopwords = extraStopwords {
                result += extraStopwords
            }
        case .custom(let isoLanguageCodeStr, let customStopwords):
            if let isoLanguageCodeStr = isoLanguageCodeStr {
                if let isoLanguageCode = ISO639LanguageCode.byStrCode(isoLanguageCodeStr),
                   let stopwords = StopwordsCollection.shared.stopwordsByLanguage(isoLanguageCode)
                {
                    result = stopwords
                } else {
                    os_log("Invalid language code \"%s\"", log: log, type: .error, isoLanguageCodeStr)
                }
            }
            if let customStopwords = customStopwords {
                result += customStopwords
            }
        case .none:
            break
        }
        return result
    }
}

/// Text analysis properties
/// - See More: [Text Analysis Keys](https://developer.apple.com/documentation/coreservices/search_kit/text_analysis_keys)
public struct TextAnalysisProperties {
    /// The minimum term length to index.
    /// - See More: [kSKMinTermLength](https://developer.apple.com/documentation/coreservices/kskmintermlength)
    var minTermLength: Int = 1

    /// A set of stopwords—words not to index.
    /// - See More: [kSKStopWords](https://developer.apple.com/documentation/coreservices/kskstopwords)
    var stopwords: Stopwords = .none

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
    ///     $0.stopwords = .auto()
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
            kSKStopWords!: Set(props.stopwords.actualStopwords),
            kSKSubstitutions!: props.substitutions,
            kSKMaximumTerms!: props.maximumTerms,
            kSKProximityIndexing!: props.proximityIndexing,
            kSKTermChars!: props.termChars,
            kSKStartTermChars!: props.startTermChars,
            kSKEndTermChars!: props.endTermChars
        ])
    }
}
