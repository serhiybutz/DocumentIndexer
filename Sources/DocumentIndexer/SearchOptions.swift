///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import CoreServices

public struct SearchOptions: OptionSet {
    /// Compute relevance scores, interpret spaces in a query as Boolean AND, do not use similarity searching.
    public static let `default` = SearchOptions(rawValue: kSKSearchOptionDefault)
    
    /// Save search time by suppressing the computation of relevance scores.
    public static let noRelevanceScores = SearchOptions(rawValue: kSKSearchOptionNoRelevanceScores)
    
    /// Interpret spaces in a query as Boolean OR.
    public static let spaceMeansOr = SearchOptions(rawValue: kSKSearchOptionSpaceMeansOR)

    /// Return references to documents that are similar to an example text string. This option ignores all query operators.
    public static let findSimilar = SearchOptions(rawValue: kSKSearchOptionFindSimilar)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
