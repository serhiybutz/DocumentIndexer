import Foundation
import DocumentIndexer

final class TestData {
    let wordOccurrences: Int
    let minWordsPerDocument: Int
    let maxWordsPerDocument: Int
    let documentOccurrences: Int
    let minWordsPerQuery: Int
    let maxWordsPerQuery: Int
    let documentURLPrefix: String

    lazy var words: [String] = (0..<wordOccurrences).map { _ in randomWord(wordLength: (1...10).randomElement()!) }

    lazy var corpus: [(DocumentURL, String)] = {
        var result: [(DocumentURL, String)] = []
        for i in (0..<documentOccurrences) {
            let documentURL = DocumentURL(URL(string: "\(documentURLPrefix)/\(i)")!)!
            let content = randomText()
            result.append((documentURL, content))
        }
        return result
    }()

    init(numberOfWords: Int = 100, minWordsPerDocument: Int = 3, maxWordsPerDocument: Int = 300, numberOfDocuments: Int = 100, minWordsPerQuery: Int = 3, maxWordsPerQuery: Int = 300, documentURLPrefix: String = ":root")
    {
        self.wordOccurrences = numberOfWords
        self.minWordsPerDocument = minWordsPerDocument
        self.maxWordsPerDocument = maxWordsPerDocument
        self.documentOccurrences = numberOfDocuments
        self.minWordsPerQuery = minWordsPerQuery
        self.maxWordsPerQuery = maxWordsPerQuery
        self.documentURLPrefix = documentURLPrefix
    }

    func randomText() -> String {
        let occurrences = (minWordsPerDocument...maxWordsPerDocument).randomElement()!
        return (0..<occurrences).map { _ in words[(0..<wordOccurrences).randomElement()!] }.reduce("", { "\($0) \($1)" })
    }

    func randomQuery() -> String {
        let occurrences = (1...5).randomElement()!
        return (0..<occurrences).map { _ in words[(0..<wordOccurrences).randomElement()!] }.reduce("", { "\($0) \($1)" })
    }

    // Source URL: https://gist.github.com/emersonbroga/f84c7490d1813902a61b
    func randomWord(wordLength: Int = 6) -> String {
        let kCons = 1
        let kVows = 2

        var cons = [
            // single consonants. Beware of Q, it"s often awkward in words
            "b", "c", "d", "f", "g", "h", "j", "k", "l", "m",
            "n", "p", "r", "s", "t", "v", "w", "x", "z",
            // possible combinations excluding those which cannot start a word
            "pt", "gl", "gr", "ch", "ph", "ps", "sh", "st", "th", "wh"
        ]

        // consonant combinations that cannot start a word
        let cons_cant_start = [
            "ck", "cm",
            "dr", "ds",
            "ft",
            "gh", "gn",
            "kr", "ks",
            "ls", "lt", "lr",
            "mp", "mt", "ms",
            "ng", "ns",
            "rd", "rg", "rs", "rt",
            "ss",
            "ts", "tch"
        ]

        let vows = [
            // single vowels
            "a", "e", "i", "o", "u", "y",
            // vowel combinations your language allows
            "ee", "oa", "oo",
        ]

        // start by vowel or consonant ?
        var current = Int(arc4random_uniform(2)) == 1 ? kCons : kVows

        var word = ""
        while word.count < wordLength {
            // After first letter, use all consonant combos
            if word.count == 2 {
                cons = cons + cons_cant_start
            }

            // random sign from either $cons or $vows
            var rnd: String = ""
            var index: Int
            if current == kCons {
                index = Int(arc4random_uniform(UInt32(cons.count)))
                rnd = cons[index]
            } else if current == kVows {
                index = Int(arc4random_uniform(UInt32(vows.count)))
                rnd = vows[index]
            }

            // check if random sign fits in word length
            let tempWord = "\(word)\(rnd)"
            if tempWord.count <= wordLength {
                word = "\(word)\(rnd)"
                // alternate sounds
                current = current == kCons ? kVows: kCons
            }
        }

        return word
    }
}
