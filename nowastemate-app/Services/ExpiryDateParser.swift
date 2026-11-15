//
//  ExpiryDateParser.swift
//  nowastemate-app
//
//  Created by Julius Nillo on 2026-11-15.
//

//  References:
//  NSRegularExpression: https://developer.apple.com/documentation/foundation/nsregularexpression
// https://www.kodeco.com/30288/nsregularexpression-tutorial-and-cheat-sheet
//  DateComponents.isValidDate: https://developer.apple.com/documentation/foundation/datecomponents/isvaliddate
// https://developer.apple.com/videos/play/wwdc2022/10025/
// https://inspection.canada.ca/en/food-labels/labelling/industry/date-markings-and-storage-instructions
// https://livehealthy.gov.nu.ca/en/node/623

import Foundation
import SwiftUI

struct ExpiryCandidate: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let matchedText: String
    let score: Int
    let isAmbiguous: Bool
}

enum ExpiryDateParser {

    // finding the patterns

    // 2026-11-15, 2026/11/15, 2026.11.15
    private static let isoRegex = makeRegex(#"\b(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})\b"#)

    private struct Match {
        let text: String
        let location: Int
        let date: Date
        let isAmbiguous: Bool
        let yearWasMissing: Bool
    }

    // seeing what is found and match each character
    // cleans the text, finds every date, and give each a score
    // +3 if best-before
    // -5 if packaged-on word
    // +1 if it's between today and 3 years
    // -2 if its more than a month past
    // thrown out so 0 or less if its more than 10 year away
    
    static func candidates(lines: [String],
                           now: Date = .now,
                           calendar: Calendar = .current) -> [ExpiryCandidate] {
        let normalized = lines.map(normalize)
        var found: [ExpiryCandidate] = []

        for line in normalized {
            for match in matches(in: line, now: now, calendar: calendar) {
                found.append(ExpiryCandidate(date: match.date, matchedText: match.text,
                                             score: 1, isAmbiguous: match.isAmbiguous))
            }
        }

        // the same date printed twice keeps its best score
        let unique = Dictionary(grouping: found, by: \.date)
            .compactMap { $0.value.max(by: { $0.score < $1.score }) }
        return unique.sorted { $0.date < $1.date }
    }

    // cleaning up the characters by upper casing them

    private static func normalize(_ raw: String) -> String {
        raw.folding(options: .diacriticInsensitive, locale: nil).uppercased()
    }

    // Matching the result for the user by score
    

    private static func matches(in line: String, now: Date, calendar: Calendar) -> [Match] {
        var result: [Match] = []

        for r in results(isoRegex, in: line) {
            guard let y = int(r, 1, line), let m = int(r, 2, line), let d = int(r, 3, line),
                  let date = makeDate(year: y, month: m, day: d, calendar: calendar) else { continue }
            result.append(Match(text: group(r, 0, line) ?? "", location: r.range.location,
                                date: date, isAmbiguous: false, yearWasMissing: false))
        }

        return result
    }

    // Dates section

 
    private static func makeDate(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone,
                                        year: year, month: month, day: day,
                                        hour: 23, minute: 59, second: 59)
        guard components.isValidDate else { return nil }
        return components.date
    }

    // functions for the regex statement above

    // the patterns are constants, so a typo crashes right away while testing
    private static func makeRegex(_ pattern: String) -> NSRegularExpression {
        try! NSRegularExpression(pattern: pattern)
    }

    private static func results(_ regex: NSRegularExpression, in text: String) -> [NSTextCheckingResult] {
        regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
    }

    private static func group(_ result: NSTextCheckingResult, _ index: Int, _ text: String) -> String? {
        guard let range = Range(result.range(at: index), in: text) else { return nil }
        return String(text[range])
    }

    private static func int(_ result: NSTextCheckingResult, _ index: Int, _ text: String) -> Int? {
        group(result, index, text).flatMap { Int($0) }
    }
}

#if DEBUG

#Preview("Parser checks") {
    let now = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 12))!
    let cases: [[String]] = [
        ["EXP 2026-11-15"],
        ["2026/02/31"]
    ]
    return List(cases, id: \.self) { lines in
        let found = ExpiryDateParser.candidates(lines: lines, now: now)
        VStack(alignment: .leading) {
            Text(lines.joined(separator: " | ")).font(.caption.monospaced())
            Text(found.isEmpty ? "nothing"
                 : found.map { "\($0.date.formatted(date: .abbreviated, time: .omitted)) (\($0.score))" }
                        .joined(separator: ", "))
        }
    }
}
#endif
