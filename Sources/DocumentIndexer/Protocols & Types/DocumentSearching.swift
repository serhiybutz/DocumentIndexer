///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

public protocol DocumentSearching {
    func makeSearch(for query: String,
                    options: SearchOptions,
                    hitsAtATime: Int,
                    maximumTime: TimeInterval) -> Search
    func search(for query: String,
                options: SearchOptions,
                hitsAtATime: Int,
                maximumTime: TimeInterval,
                completion: (_ hits: [SearchHit], _ hasMore: Bool, _ shouldStop: inout Bool) -> Void)
}
