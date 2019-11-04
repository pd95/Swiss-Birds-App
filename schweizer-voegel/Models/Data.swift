//
//  Data.swift
//  schweizer-voegel
//
//  Created by Philipp on 01.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

let allSpecies: [Species] = loadSpeciesData(filename: "vds-list-de")

func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
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
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}



func loadSpeciesData(filename: String) -> [Species] {
    let data: Data
    var species = [Species]()

    guard let file = Bundle.main.url(forResource: filename, withExtension: "json")
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let jsonResult = try JSONSerialization.jsonObject(with: data)
        if let jsonResult = jsonResult as? Array<Dictionary<String, AnyObject>> {
            species = jsonResult.map { (jsonObj) -> Species in
                
                let filterlebensraum = jsonObj["filterlebensraum"] as? String ?? ""
                let filtervogelgruppe = jsonObj["filtervogelgruppe"] as? String ?? ""
                let filternahrung = jsonObj["filternahrung"] as? String ?? ""
                let filterhaeufigeart = jsonObj["filterhaeufigeart"] as? String ?? ""
                let filterrotelistech = jsonObj["filterrotelistech"] as? String ?? ""
                let filterentwicklungatlas = jsonObj["filterentwicklungatlas"] as? String ?? ""
                
                return Species(speciesId: Int(jsonObj["ArtId"] as! String)!,
                               name: jsonObj["Artname"] as! String,
                               alternateName: jsonObj["Alternativ_Name"] as! String,
                               filterMap: [
                                FilterType(rawValue: "filterlebensraum")! : filterlebensraum.split(separator: ",").map({ (s) -> Int in
                                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                                }),
                                FilterType(rawValue: "filtervogelguppe")! : [Int(filtervogelgruppe)!],
                                FilterType(rawValue: "filternahrung")! : filternahrung.split(separator: ",").map({ (s) -> Int in
                                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                                }),
                                FilterType(rawValue: "filterhaeufigeart")! : [Int(filterhaeufigeart)!],
                                FilterType(rawValue: "filterrotelistech")! : (filterrotelistech.count > 0 ? [Int(filterrotelistech)!]:[]),
                                FilterType(rawValue: "filterentwicklungatlas")! : (filterentwicklungatlas.count > 0 ? [Int(filterentwicklungatlas)!]:[]),
                ])
            }
        }
    } catch {
        fatalError("Unable to decode JSON of \(filename):\n\(error)")
    }
    
    return species.sorted { $0.name <= $1.name }
}


let allFilters : [String:Filter] = [
    "filterhaeufigeart-0":Filter(filterId: 0, name: "Selten", type: FilterType(rawValue: "filterhaeufigeart")!),
    "filterhaeufigeart-1":Filter(filterId: 1, name: "Häufig", type: FilterType(rawValue: "filterhaeufigeart")!),
    "filterlebensraum-1":Filter(filterId: 1, name: "felsiges Gelände", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-2":Filter(filterId: 2, name: "Feuchtgebiete", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-3":Filter(filterId: 3, name: "Gewässer", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-4":Filter(filterId: 4, name: "Hochgebirge", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-5":Filter(filterId: 5, name: "Wald", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-6":Filter(filterId: 6, name: "Ödland", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-7":Filter(filterId: 7, name: "halboffenes Kulturland", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-8":Filter(filterId: 8, name: "Ackerland", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-9":Filter(filterId: 9, name: "Wiesen und Weiden", type: FilterType(rawValue: "filterlebensraum")!),
    "filterlebensraum-10":Filter(filterId: 10, name: "Siedlungen", type: FilterType(rawValue: "filterlebensraum")!),
    "filternahrung-1":Filter(filterId: 1, name: "Aas", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-2":Filter(filterId: 2, name: "Abfall", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-3":Filter(filterId: 3, name: "Allesfresser", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-4":Filter(filterId: 4, name: "Amphibien", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-5":Filter(filterId: 5, name: "Insekten und Spinnen", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-6":Filter(filterId: 6, name: "Samen", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-7":Filter(filterId: 7, name: "Früchte", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-8":Filter(filterId: 8, name: "Fische", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-9":Filter(filterId: 9, name: "Säuger", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-10":Filter(filterId: 10, name: "Pflanzen", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-11":Filter(filterId: 11, name: "andere Wassertiere", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-12":Filter(filterId: 12, name: "Reptilien", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-13":Filter(filterId: 13, name: "Schnecken", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-14":Filter(filterId: 14, name: "Vögel", type: FilterType(rawValue: "filternahrung")!),
    "filternahrung-15":Filter(filterId: 15, name: "Würmer", type: FilterType(rawValue: "filternahrung")!),
    "filterrotelistech-1":Filter(filterId: 1, name: "nicht gefährdet (LC)", type: FilterType(rawValue: "filterrotelistech")!),
    "filterrotelistech-2":Filter(filterId: 2, name: "potenziell gefährdet (NT)", type: FilterType(rawValue: "filterrotelistech")!),
    "filterrotelistech-3":Filter(filterId: 3, name: "verletzlich (VU)", type: FilterType(rawValue: "filterrotelistech")!),
    "filterrotelistech-4":Filter(filterId: 4, name: "stark gefährdet (EN)", type: FilterType(rawValue: "filterrotelistech")!),
    "filterrotelistech-5":Filter(filterId: 5, name: "vom Aussterben bedroht (CR)", type: FilterType(rawValue: "filterrotelistech")!),
    "filterrotelistech-6":Filter(filterId: 6, name: "ausgestorben (RE)", type: FilterType(rawValue: "filterrotelistech")!),
    "filtervogelguppe-1":Filter(filterId: 1, name: "Alken", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-2":Filter(filterId: 2, name: "Ammern", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-3":Filter(filterId: 3, name: "Austernfischer", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-4":Filter(filterId: 4, name: "Baumläufer", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-5":Filter(filterId: 5, name: "Beutelmeisen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-6":Filter(filterId: 6, name: "Bienenfresser", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-7":Filter(filterId: 7, name: "Braunellen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-8":Filter(filterId: 8, name: "Drosselvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-9":Filter(filterId: 9, name: "Eisvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-10":Filter(filterId: 10, name: "Entenvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-11":Filter(filterId: 11, name: "Falken", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-12":Filter(filterId: 12, name: "Finkenvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-13":Filter(filterId: 13, name: "Fischadler", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-14":Filter(filterId: 14, name: "Flamingos", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-15":Filter(filterId: 15, name: "Fliegenschnäpper", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-16":Filter(filterId: 16, name: "Flughühner", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-17":Filter(filterId: 17, name: "Glattfusshühner", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-18":Filter(filterId: 18, name: "Habichtartige", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-19":Filter(filterId: 19, name: "Ibisse", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-20":Filter(filterId: 20, name: "Kleiber", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-21":Filter(filterId: 21, name: "Kormorane", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-22":Filter(filterId: 22, name: "Kraniche", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-23":Filter(filterId: 23, name: "Kuckucke", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-24":Filter(filterId: 24, name: "Lappentaucher", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-25":Filter(filterId: 25, name: "Lerchen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-26":Filter(filterId: 26, name: "Löffler", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-27":Filter(filterId: 27, name: "Mauerläufer", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-28":Filter(filterId: 28, name: "Meisen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-29":Filter(filterId: 29, name: "Möwen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-30":Filter(filterId: 30, name: "Nachtschwalben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-31":Filter(filterId: 31, name: "Ohreulen und Käuze", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-32":Filter(filterId: 32, name: "Pelikane", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-33":Filter(filterId: 33, name: "Pieper und Stelzen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-34":Filter(filterId: 34, name: "Pirole", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-35":Filter(filterId: 35, name: "Rabenvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-36":Filter(filterId: 36, name: "Racken", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-37":Filter(filterId: 37, name: "Rallen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-38":Filter(filterId: 38, name: "Raubmöwen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-39":Filter(filterId: 39, name: "Raufusshühner", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-40":Filter(filterId: 40, name: "Regenpfeifer", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-41":Filter(filterId: 41, name: "Reiher", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-42":Filter(filterId: 42, name: "Rennvögel und Brachschwalben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-43":Filter(filterId: 43, name: "Schleiereulen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-44":Filter(filterId: 44, name: "Schnepfen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-45":Filter(filterId: 45, name: "Schwalben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-46":Filter(filterId: 46, name: "Schwanzmeisen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-47":Filter(filterId: 47, name: "Seeschwalben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-48":Filter(filterId: 48, name: "Seetaucher", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-49":Filter(filterId: 49, name: "Segler", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-50":Filter(filterId: 50, name: "Seidenschwänze", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-51":Filter(filterId: 51, name: "Spechte", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-52":Filter(filterId: 52, name: "Sperlinge", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-53":Filter(filterId: 53, name: "Starenvögel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-54":Filter(filterId: 54, name: "Stelzenläufer und Säbelschnäbler", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-55":Filter(filterId: 55, name: "Störche", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-56":Filter(filterId: 56, name: "Sturmschwalben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-57":Filter(filterId: 57, name: "Sturmtaucher", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-58":Filter(filterId: 58, name: "Tauben", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-59":Filter(filterId: 59, name: "Timalien", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-60":Filter(filterId: 60, name: "Tölpel", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-61":Filter(filterId: 61, name: "Trappen", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-62":Filter(filterId: 62, name: "Triele", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-63":Filter(filterId: 63, name: "Wasseramseln", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-64":Filter(filterId: 64, name: "Wiedehopfe", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-65":Filter(filterId: 65, name: "Würger", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-66":Filter(filterId: 66, name: "Zaunkönige", type: FilterType(rawValue: "filtervogelguppe")!),
    "filtervogelguppe-67":Filter(filterId: 67, name: "Zweigsänger", type: FilterType(rawValue: "filtervogelguppe")!),
    "filterentwicklungatlas-1":Filter(filterId: 1, name: "starke Zunahme", type: FilterType(rawValue: "filterentwicklungatlas")!),
    "filterentwicklungatlas-2":Filter(filterId: 2, name: "moderate Zunahme", type: FilterType(rawValue: "filterentwicklungatlas")!),
    "filterentwicklungatlas-3":Filter(filterId: 3, name: "stabile Entwicklung", type: FilterType(rawValue: "filterentwicklungatlas")!),
    "filterentwicklungatlas-4":Filter(filterId: 4, name: "moderate Abnahme", type: FilterType(rawValue: "filterentwicklungatlas")!),
    "filterentwicklungatlas-5":Filter(filterId: 5, name: "starke Abnahme", type: FilterType(rawValue: "filterentwicklungatlas")!)
];

