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

    private static let monthCodes = ["JA", "FE", "MR", "AL", "MA", "JN", "JL", "AU", "SE", "OC", "NO", "DE"]
    
    // 2026 NO 15, 26 NO 15, NO 15 (year optional, Canadian YY MM DD order)
    // CFIA date markings: https://inspection.canada.ca/en/food-labels/labelling/industry/date-markings-and-storage-instructions
    private static let monthCodeRegex = makeRegex(#"\b(?:(\d{4}|\d{2})\s+)?(JA|FE|MR|AL|MA|JN|JL|AU|SE|OC|NO|DE)\s+(\d{1,2})\b"#)

    private static let expiryKeywordRegex = makeRegex(#"\b(EXP|EXPIRY|EXPIRES|BB|BBE|BEST BEFORE|BEST BY|USE BY|MEILLEUR AVANT)\b"#)
    private static let packagedOnRegex = makeRegex(#"\b(PACKAGED ON|PACKED ON|EMBALLE LE|PKD|MFG|PROD|LOT)\b"#)

    private enum Label { case expiry, packagedOn }
    
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
    
    static func candidates(lines: [String], now: Date = .now, calendar: Calendar = .current) -> [ExpiryCandidate] {
        let normalized = lines.map(normalize)
        var found: [ExpiryCandidate] = []
        
        for (index, line) in normalized.enumerated() {
            let labelAbove = index > 0 ? label(before: .max, in: normalized[index - 1]) : nil
            
            for match in matches(in: line, now: now, calendar: calendar) {
                // the nearest label before the date on its own line, otherwise the line above
                let label = label(before: match.location, in: line) ?? labelAbove
                
                // "NO 15" with no year is only a date if a best-before keyword is right there
                if match.yearWasMissing && label != .expiry { continue }
                
                var score = 0
                if label == .expiry { score += 3 }
                if label == .packagedOn { score -= 5 }
                
                found.append(ExpiryCandidate(date: match.date, matchedText: match.text, score: score, isAmbiguous: match.isAmbiguous))
            }
        }
        
        let unique = Dictionary(grouping: found, by: \.date).compactMap { $0.value.max(by: { $0.score < $1.score }) }
        return unique
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
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
        
        for r in results(monthCodeRegex, in: line) {
            guard let code = group(r, 2, line),
                  let monthIndex = monthCodes.firstIndex(of: code),
                  let day = int(r, 3, line) else { continue }
            let year = int(r, 1, line)
            let date = year.map { makeDate(year: fullYear($0), month: monthIndex + 1, day: day, calendar: calendar) }
            ?? nextOccurrence(month: monthIndex + 1, day: day, now: now, calendar: calendar)
            guard let date else { continue }
            result.append(Match(text: group(r, 0, line) ?? "", location: r.range.location,date: date, isAmbiguous: false, yearWasMissing: year == nil))
        }

        return result
    }

    // Labels section

    // the closest keyword before `location`; Int.max means "the last one on the line"
    private static func label(before location: Int, in line: String) -> Label? {
        let labels = results(expiryKeywordRegex, in: line).map { ($0.range.location, Label.expiry) }
                   + results(packagedOnRegex, in: line).map { ($0.range.location, Label.packagedOn) }
        return labels.filter { $0.0 < location }.max(by: { $0.0 < $1.0 })?.1
    }
    
    // Dates section
    private static func makeDate(year: Int, month: Int, day: Int, calendar: Calendar) -> Date? {
        let components = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: 23, minute: 59, second: 59)
        guard components.isValidDate else { return nil }
        return components.date
    }
    
    // "NO 15" with no year means the next 15 Nov, today included (up to 4 years ahead, for 29 Feb)
    private static func nextOccurrence(month: Int, day: Int, now: Date, calendar: Calendar) -> Date? {
        let thisYear = calendar.component(.year, from: now)
        let today = calendar.startOfDay(for: now)
        for year in thisYear...(thisYear + 4) {
            if let date = makeDate(year: year, month: month, day: day, calendar: calendar), date >= today {
                return date
            }
        }
        return nil
    }

    private static func fullYear(_ year: Int) -> Int { year < 100 ? 2000 + year : year }

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
        ["BEST BEFORE", "2026 NO 15"],
        ["MEILLEUR AVANT / BEST BEFORE 26 NO 15"],
        ["BEST BEFORE NO 15"],
        ["BEST BEFORE", "NO 05"],
        ["NO 15"],
        ["NO SUGAR ADDED", "MA 12"],
        ["PACKAGED ON 26 NO 01", "BEST BEFORE 26 NO 20"]
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
