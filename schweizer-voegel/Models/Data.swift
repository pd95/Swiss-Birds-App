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
                                .lebensraum : filterlebensraum.split(separator: ",").map({ (s) -> Int in
                                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                                }),
                                .vogelgruppe : [Int(filtervogelgruppe)!],
                                .nahrung : filternahrung.split(separator: ",").map({ (s) -> Int in
                                    return Int(String(s.trimmingCharacters(in: .whitespaces)))!
                                }),
                                .haeufigeart : [Int(filterhaeufigeart)!],
                                .roteListe : (filterrotelistech.count > 0 ? [Int(filterrotelistech)!]:[]),
                                .entwicklungatlas : (filterentwicklungatlas.count > 0 ? [Int(filterentwicklungatlas)!]:[]),
                    ]
                )
            }
        }
    } catch {
        fatalError("Unable to decode JSON of \(filename):\n\(error)")
    }
    
    return species.sorted { $0.name <= $1.name }
}


let allFilters : [FilterType:[Filter]] = [
    .haeufigeart : [
        Filter(filterId: 0, name: "Selten", type: .haeufigeart),
        Filter(filterId: 1, name: "Häufig", type: .haeufigeart)
    ],
    .lebensraum : [
        Filter(filterId: 1, name: "felsiges Gelände", type: .lebensraum),
        Filter(filterId: 2, name: "Feuchtgebiete", type: .lebensraum),
        Filter(filterId: 3, name: "Gewässer", type: .lebensraum),
        Filter(filterId: 4, name: "Hochgebirge", type: .lebensraum),
        Filter(filterId: 5, name: "Wald", type: .lebensraum),
        Filter(filterId: 6, name: "Ödland", type: .lebensraum),
        Filter(filterId: 7, name: "halboffenes Kulturland", type: .lebensraum),
        Filter(filterId: 8, name: "Ackerland", type: .lebensraum),
        Filter(filterId: 9, name: "Wiesen und Weiden", type: .lebensraum),
        Filter(filterId: 10, name: "Siedlungen", type: .lebensraum),
    ],
    .nahrung : [
        Filter(filterId: 1, name: "Aas", type: .nahrung),
        Filter(filterId: 2, name: "Abfall", type: .nahrung),
        Filter(filterId: 3, name: "Allesfresser", type: .nahrung),
        Filter(filterId: 4, name: "Amphibien", type: .nahrung),
        Filter(filterId: 5, name: "Insekten und Spinnen", type: .nahrung),
        Filter(filterId: 6, name: "Samen", type: .nahrung),
        Filter(filterId: 7, name: "Früchte", type: .nahrung),
        Filter(filterId: 8, name: "Fische", type: .nahrung),
        Filter(filterId: 9, name: "Säuger", type: .nahrung),
        Filter(filterId: 10, name: "Pflanzen", type: .nahrung),
        Filter(filterId: 11, name: "andere Wassertiere", type: .nahrung),
        Filter(filterId: 12, name: "Reptilien", type: .nahrung),
        Filter(filterId: 13, name: "Schnecken", type: .nahrung),
        Filter(filterId: 14, name: "Vögel", type: .nahrung),
        Filter(filterId: 15, name: "Würmer", type: .nahrung),
    ],
    .roteListe : [
        Filter(filterId: 1, name: "nicht gefährdet (LC)", type: .roteListe),
        Filter(filterId: 2, name: "potenziell gefährdet (NT)", type: .roteListe),
        Filter(filterId: 3, name: "verletzlich (VU)", type: .roteListe),
        Filter(filterId: 4, name: "stark gefährdet (EN)", type: .roteListe),
        Filter(filterId: 5, name: "vom Aussterben bedroht (CR)", type: .roteListe),
        Filter(filterId: 6, name: "ausgestorben (RE)", type: .roteListe),
    ],
    .vogelgruppe : [
        Filter(filterId: 1, name: "Alken", type: .vogelgruppe),
        Filter(filterId: 2, name: "Ammern", type: .vogelgruppe),
        Filter(filterId: 3, name: "Austernfischer", type: .vogelgruppe),
        Filter(filterId: 4, name: "Baumläufer", type: .vogelgruppe),
        Filter(filterId: 5, name: "Beutelmeisen", type: .vogelgruppe),
        Filter(filterId: 6, name: "Bienenfresser", type: .vogelgruppe),
        Filter(filterId: 7, name: "Braunellen", type: .vogelgruppe),
        Filter(filterId: 8, name: "Drosselvögel", type: .vogelgruppe),
        Filter(filterId: 9, name: "Eisvögel", type: .vogelgruppe),
        Filter(filterId: 10, name: "Entenvögel", type: .vogelgruppe),
        Filter(filterId: 11, name: "Falken", type: .vogelgruppe),
        Filter(filterId: 12, name: "Finkenvögel", type: .vogelgruppe),
        Filter(filterId: 13, name: "Fischadler", type: .vogelgruppe),
        Filter(filterId: 14, name: "Flamingos", type: .vogelgruppe),
        Filter(filterId: 15, name: "Fliegenschnäpper", type: .vogelgruppe),
        Filter(filterId: 16, name: "Flughühner", type: .vogelgruppe),
        Filter(filterId: 17, name: "Glattfusshühner", type: .vogelgruppe),
        Filter(filterId: 18, name: "Habichtartige", type: .vogelgruppe),
        Filter(filterId: 19, name: "Ibisse", type: .vogelgruppe),
        Filter(filterId: 20, name: "Kleiber", type: .vogelgruppe),
        Filter(filterId: 21, name: "Kormorane", type: .vogelgruppe),
        Filter(filterId: 22, name: "Kraniche", type: .vogelgruppe),
        Filter(filterId: 23, name: "Kuckucke", type: .vogelgruppe),
        Filter(filterId: 24, name: "Lappentaucher", type: .vogelgruppe),
        Filter(filterId: 25, name: "Lerchen", type: .vogelgruppe),
        Filter(filterId: 26, name: "Löffler", type: .vogelgruppe),
        Filter(filterId: 27, name: "Mauerläufer", type: .vogelgruppe),
        Filter(filterId: 28, name: "Meisen", type: .vogelgruppe),
        Filter(filterId: 29, name: "Möwen", type: .vogelgruppe),
        Filter(filterId: 30, name: "Nachtschwalben", type: .vogelgruppe),
        Filter(filterId: 31, name: "Ohreulen und Käuze", type: .vogelgruppe),
        Filter(filterId: 32, name: "Pelikane", type: .vogelgruppe),
        Filter(filterId: 33, name: "Pieper und Stelzen", type: .vogelgruppe),
        Filter(filterId: 34, name: "Pirole", type: .vogelgruppe),
        Filter(filterId: 35, name: "Rabenvögel", type: .vogelgruppe),
        Filter(filterId: 36, name: "Racken", type: .vogelgruppe),
        Filter(filterId: 37, name: "Rallen", type: .vogelgruppe),
        Filter(filterId: 38, name: "Raubmöwen", type: .vogelgruppe),
        Filter(filterId: 39, name: "Raufusshühner", type: .vogelgruppe),
        Filter(filterId: 40, name: "Regenpfeifer", type: .vogelgruppe),
        Filter(filterId: 41, name: "Reiher", type: .vogelgruppe),
        Filter(filterId: 42, name: "Rennvögel und Brachschwalben", type: .vogelgruppe),
        Filter(filterId: 43, name: "Schleiereulen", type: .vogelgruppe),
        Filter(filterId: 44, name: "Schnepfen", type: .vogelgruppe),
        Filter(filterId: 45, name: "Schwalben", type: .vogelgruppe),
        Filter(filterId: 46, name: "Schwanzmeisen", type: .vogelgruppe),
        Filter(filterId: 47, name: "Seeschwalben", type: .vogelgruppe),
        Filter(filterId: 48, name: "Seetaucher", type: .vogelgruppe),
        Filter(filterId: 49, name: "Segler", type: .vogelgruppe),
        Filter(filterId: 50, name: "Seidenschwänze", type: .vogelgruppe),
        Filter(filterId: 51, name: "Spechte", type: .vogelgruppe),
        Filter(filterId: 52, name: "Sperlinge", type: .vogelgruppe),
        Filter(filterId: 53, name: "Starenvögel", type: .vogelgruppe),
        Filter(filterId: 54, name: "Stelzenläufer und Säbelschnäbler", type: .vogelgruppe),
        Filter(filterId: 55, name: "Störche", type: .vogelgruppe),
        Filter(filterId: 56, name: "Sturmschwalben", type: .vogelgruppe),
        Filter(filterId: 57, name: "Sturmtaucher", type: .vogelgruppe),
        Filter(filterId: 58, name: "Tauben", type: .vogelgruppe),
        Filter(filterId: 59, name: "Timalien", type: .vogelgruppe),
        Filter(filterId: 60, name: "Tölpel", type: .vogelgruppe),
        Filter(filterId: 61, name: "Trappen", type: .vogelgruppe),
        Filter(filterId: 62, name: "Triele", type: .vogelgruppe),
        Filter(filterId: 63, name: "Wasseramseln", type: .vogelgruppe),
        Filter(filterId: 64, name: "Wiedehopfe", type: .vogelgruppe),
        Filter(filterId: 65, name: "Würger", type: .vogelgruppe),
        Filter(filterId: 66, name: "Zaunkönige", type: .vogelgruppe),
        Filter(filterId: 67, name: "Zweigsänger", type: .vogelgruppe),
    ],
    .entwicklungatlas : [
        Filter(filterId: 1, name: "starke Zunahme", type: .entwicklungatlas),
        Filter(filterId: 2, name: "moderate Zunahme", type: .entwicklungatlas),
        Filter(filterId: 3, name: "stabile Entwicklung", type: .entwicklungatlas),
        Filter(filterId: 4, name: "moderate Abnahme", type: .entwicklungatlas),
        Filter(filterId: 5, name: "starke Abnahme", type: .entwicklungatlas)
    ],
];
