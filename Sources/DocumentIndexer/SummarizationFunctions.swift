///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import CoreServices

/// Generates a summary string based on a text string.
///
/// - Parameters:
///   - text: The text string to summarize.
///   - numSentences: The maximum number of sentences in the summary.
/// - Returns: A string containing the requested summary.
/// - See Also: [Search Kit](https://developer.apple.com/documentation/coreservices/search_kit), [SKSummaryCreateWithString](https://developer.apple.com/documentation/coreservices/1446229-sksummarycreatewithstring), [SKSummaryCopySentenceSummaryString](https://developer.apple.com/documentation/coreservices/1449700-sksummarycopysentencesummarystri)
public func summarizeOnSentenceBasis(text: String, numSentences: Int) -> String? {
    guard let summary = SKSummaryCreateWithString(text as CFString)?.takeRetainedValue() else { return nil }
    return SKSummaryCopySentenceSummaryString(summary, numSentences)?.takeRetainedValue() as String?
}

/// Generates a summary string based on a text string.
///
/// - Parameters:
///   - text: The text string to summarize.
///   - numParagraphs: The maximum number of paragraphs in the summary.
/// - Returns: A string containing the requested summary.
/// - See Also: [Search Kit](https://developer.apple.com/documentation/coreservices/search_kit), [SKSummaryCreateWithString](https://developer.apple.com/documentation/coreservices/1446229-sksummarycreatewithstring), [SKSummaryCopyParagraphSummaryString](https://developer.apple.com/documentation/coreservices/1449746-sksummarycopyparagraphsummarystr)
public func summarizeOnParagraphBasis(text: String, numParagraphs: Int) -> String? {
    guard let summary = SKSummaryCreateWithString(text as CFString)?.takeRetainedValue() else { return nil }
    return SKSummaryCopyParagraphSummaryString(summary, numParagraphs)?.takeRetainedValue() as String?
}
