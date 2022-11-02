///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A base class for backing `SKIndex` wrappers.
class Index: IndexProvider {
    // MARK: - Life cycle

    var index: SKIndex { preconditionFailure("Must override") }

    // MARK: - Initialization

// No need for explicit closing as it's done automatically
//    deinit {
//        SKIndexClose(index)
//    }
}
