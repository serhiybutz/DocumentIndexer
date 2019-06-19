///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// Auto-flush strategy
public enum AutoflushStrategy {
    /// Opt in to performing automatic flushing before each search.
    case beforeEachSearch
    /// Opt in to performing automatic flushing after each update.
    case afterEachUpdate
    /// Opt out of performing automatic flushing.
    case none
}
