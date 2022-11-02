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
                            category: "Stopwords Collection")

struct StopwordsCollection {
    // MARK: - Constants

    static let filename = "stopwords-iso.json"

    // MARK: - State

    private
    let codeToStopwordsMap: [ISO639LanguageCode: [String]]

    static let shared: StopwordsCollection = {
        switch StopwordsCollection.load() {
        case .success(let result):
            return result
        case .failure(let error):
            os_log("%@", log: log, type: .error, error.localizedDescription)
            return StopwordsCollection([:])
        }
    }()

    // MARK: - Properties

    func stopwordsByLanguage(_ language: ISO639LanguageCode) -> [String]? { codeToStopwordsMap[language] }

    // MARK: - Initialization

    private
    init(_ stopwordsByLanguage: [ISO639LanguageCode: [String]]) {
        self.codeToStopwordsMap = stopwordsByLanguage
    }

    // MARK: - Helpers

    private
    static func load() -> Result<StopwordsCollection, LoadError> {
        // Get URL of stopwords json file
        guard let url = Bundle.module.url(forResource: filename, withExtension: nil) else {
            return .failure(.failedToLocateFile(fileName: filename))
        }

        guard let data = try? Data(contentsOf: url) else {
            return .failure(.failedToLoadFile(fileName: filename))
        }

        let decoder = JSONDecoder()
        do {
            let dict = try decoder.decode([String: [String]].self, from: data)
            var stopwords: [ISO639LanguageCode: [String]] = [:]
            for (key, value) in dict {
                guard let isoKey = ISO639LanguageCode.byStrCode(key) else {
                    os_log("Unknown ISO 639-1 key: %@", type: .info, key)
                    continue
                }
                stopwords[isoKey] = value
            }
            return .success(StopwordsCollection(stopwords))
        } catch {
            return .failure(LoadError.failedToDecodeJSON(underlyingError: error))
        }
    }

    public enum LoadError: Swift.Error, LocalizedError {
        case failedToLocateFile(fileName: String)
        case failedToLoadFile(fileName: String)
        case failedToDecodeJSON(underlyingError: Swift.Error)
        public var errorDescription: String? {
            switch self {
            case .failedToLocateFile(let fileName):
                return NSLocalizedString("Failed to locate file \"\(fileName)\"", comment: "File locating error")
            case .failedToLoadFile(let fileName):
                return NSLocalizedString("Failed to load file \"\(fileName)\"", comment: "File loading error")
            case .failedToDecodeJSON(let underlyingError):
                return NSLocalizedString("Failed to decode JSON due to: \(underlyingError)", comment: "JSON decoding error")
            }
        }
    }
}
