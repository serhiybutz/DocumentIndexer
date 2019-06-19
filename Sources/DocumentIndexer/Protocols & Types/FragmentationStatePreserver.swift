///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A fragmentation state provider.
///
/// The fragmentation state preservation is optional and delegated to a state preserver implemented by the user.
/// The fragmentation state preserver should conform to the protocol `FragmentationStatePreserver`. It's instance is provided at the time of creating (for an on-disk indexer - both creating and loading) the document indexer. The preserver's only responsibility is to persist the provided piece of information in any way by being able of storing and restoring it at request.
/// # Example of a fragmantation state preserver:
/// ```
/// struct IndexerFragmentationStatePreserver: FragmentationStatePreserver {
///     func preserve(_ state: FragmentationState) {
///         UserDefaults.standard.setValue(state.maximumDocumentID, forKey: "maximumDocumentID")
///         UserDefaults.standard.setValue(state.documentCount, forKey: "documentCount")
///     }
///     func restore() -> FragmentationState {
///         guard let maximumDocumentID = UserDefaults.standard.object(forKey: "maximumDocumentID") as? Int,
///               let documentCount = UserDefaults.standard.object(forKey: "documentCount") as? Int
///         else { preconditionFailure() }
///
///         return (maximumDocumentID: maximumDocumentID,
///                 documentCount: documentCount)
///    }
/// }
/// ```
public protocol FragmentationStatePreserver {
    typealias FragmentationState = (maximumDocumentID: Int, documentCount: Int)
    func preserve(_ : FragmentationState)
    func restore() -> FragmentationState
}
