//
//  Utility.swift
//  mysic
//
//  Created by mac on 25/06/23.
//

import Foundation

class Utility: NSObject {
    
    private static var timeHMSFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    static func formatSecondsToHMS(_ seconds: Double) -> String {
        guard !seconds.isNaN,
            let text = timeHMSFormatter.string(from: seconds) else {
                return "00:00"
        }
         
        return text
    }
    
}

func loadJSONFile<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else{
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch DecodingError.keyNotFound(let key, let context) {
        fatalError("Failed to decode \(filename) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription)")
    } catch DecodingError.typeMismatch(_, let context) {
        fatalError("Failed to decode \(filename) from bundle due to type mismatch - \(context.debugDescription)")
    } catch DecodingError.valueNotFound(let type, let context) {
        fatalError("Failed to decode \(filename) from bundle due to missing \(type) value = \(context.debugDescription)")
    } catch DecodingError.dataCorrupted(_) {
        fatalError("Failed to decode \(filename) from bundle because it appears to be invalid JSON.")
    } catch {
        fatalError("Failed to decode \(filename) from bundle: \(error.localizedDescription)")
    }
}
