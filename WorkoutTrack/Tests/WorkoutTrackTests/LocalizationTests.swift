//
//  LocalizationTests.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/8/20.
//

import XCTest
@testable import WorkoutTrack

final class LocalizationTests: XCTestCase {

    func test_localizedString_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Exercises"
        let bundle = ExercisesPresentationResources.bundle
        print("Bundle path: \(bundle.bundlePath)")
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
    
    private func assertLocalizedKeyAndValuesExist(in presentationBundle: Bundle, _ table: String, file: StaticString = #filePath, line: UInt = #line) {
        let localizationBundles = allLocalizationBundles(in: presentationBundle, file: file, line: line)
        let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table, file: file, line: line)
        
        localizationBundles.forEach { (bundle, localization) in
            localizedStringKeys.forEach { key in
                let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
                
                if localizedString == key {
                    let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                    XCTFail("Missing \(language) (\(localization)) localized string for key: '\(key)' in table: '\(table)'", file: (file), line: line)
                }
            }
        }
    }
    
    typealias LocalizedBundle = (bundle: Bundle, localization: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                return nil
            }
            
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard let path = current.bundle.path(forResource: table, ofType: "strings"),
                  let strings = NSDictionary(contentsOfFile: path),
                  let keys = strings.allKeys as? [String]
            else {
                XCTFail("Coudln't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }
        
            return acc.union(Set(keys))
        }
    }
}
