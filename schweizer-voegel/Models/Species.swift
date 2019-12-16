//
//  Arten.swift
//  schweizer-voegel
//
//  Created by Philipp on 31.10.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Species: Identifiable, Hashable, CustomStringConvertible {
    let id = UUID()

    let speciesId : Int
    let name : String
    let alternateName : String
    
    let filterMap : [FilterType: [Int]]  // For each FilterType an array of related IDs

    func filterSymbolName(_ filterType : FilterType) -> String {
        if let array = filterMap[filterType], array.count > 0 {
            return "\(filterType.rawValue)-\(array[0])"
        }
        return ""
    }
    
    func nameMatches(_ text: String) -> Bool {
        if text.count == 0 {
            return true
        }
        let lowercaseName = name.lowercased() + " " + alternateName.lowercased()
        for word in text.lowercased().split(separator: " ") {
            if lowercaseName.contains(word) {
                return true
            }
        }
        return false
    }
    
    func categoryMatches(filters: [FilterType: [Int]]) -> Bool {
        if filters.count == 0 {
            return true
        }
        
        var matchesAll = true
        for (type, relevantIds) in filters {
            matchesAll = matchesAll && (filterMap[type] ?? []).reduce(false, { $0 || relevantIds.contains($1)})
        }
        
        return matchesAll
    }
    
    var description: String {
        return "Species(speciesId=\(speciesId), name=\(name), filterMap=\(filterMap))"
    }
}

struct SpeciesDetail: Codable {
    let artID, sysNr, artname: String
    let alternativName: String?
    let artnameLat, infos, roteListeCH, zugverhalten: String?
    let laengeCM, gewichtG, gelegegroesse, brutort: String?
    let brutdauerTage, nestlingsdauerFlugfaehigkeitTage: String?
    let nahrung, vogelgruppe, lebensraum, artnameFrz: String?
    let artnameItal, artnameRr, artnameEngl, artnameSpan: String?
    let artnameHoll, familieWiss, familieDt, spannweiteCM: String?
    let hoechstalterEURING, hoechstalterCH, jahresbruten, statusInCH: String?
    let prioritaetsartArtenfoerderung, videosBilderStimmen, federnbestimmung, globaleSituationBirdLifeInternational: String?
    let synonyme, chBestandPeriode, merkmale, autor0: String?
    let bezeichnungDe0, autor1, bezeichnungDe1, autor2: String?
    let bezeichnungDe2, filternahrung, filterlebensraum, filterhaeufigeart: String?
    let filterrotelistech, filtervogelgruppe, filterentwicklungatlas, atlastext: String?
    let literatur, atlasautor, bestand, bestandDatum: String?
    let entwicklung, atlasLebensraum, roteListe, partner1: String?
    let partner2, partner3, partner4, partner5: String?
    let density, densityChange: String?
    let occupancy, occupancyChange, point, pointChange: String?
    let distribution, record, migration, winter: String?
    let water, index, indexMigrant, trendWater: String?
    let trendRecord, phenology, phenologyRecord, altitude: String?
    let altitudeChange, annualCycle, alias, uri: String?
    let uriDe, uriFr, uriIt, uriEn: String?
    
    enum CodingKeys: String, CodingKey {
        case artID = "ArtId"
        case sysNr = "Sys_Nr"
        case artname = "Artname"
        case alternativName = "Alternativ_Name"
        case artnameLat = "Artname_Lat"
        case infos = "Infos"
        case roteListeCH = "Rote_Liste_CH"
        case zugverhalten = "Zugverhalten"
        case laengeCM = "Laenge_cm"
        case gewichtG = "Gewicht_g"
        case gelegegroesse = "Gelegegroesse"
        case brutort = "Brutort"
        case brutdauerTage = "Brutdauer_Tage"
        case nestlingsdauerFlugfaehigkeitTage = "Nestlingsdauer_Flugfaehigkeit_Tage"
        case nahrung = "Nahrung"
        case vogelgruppe = "Vogelgruppe"
        case lebensraum = "Lebensraum"
        case artnameFrz = "Artname_frz"
        case artnameItal = "Artname_ital"
        case artnameRr = "Artname_rr"
        case artnameEngl = "Artname_engl"
        case artnameSpan = "Artname_span"
        case artnameHoll = "Artname_holl"
        case familieWiss = "Familie_wiss"
        case familieDt = "Familie_dt"
        case spannweiteCM = "Spannweite_cm"
        case hoechstalterEURING = "Hoechstalter_EURING"
        case hoechstalterCH = "Hoechstalter_CH"
        case jahresbruten = "Jahresbruten"
        case statusInCH = "Status_in_CH"
        case prioritaetsartArtenfoerderung = "Prioritaetsart_Artenfoerderung"
        case videosBilderStimmen = "Videos_Bilder_Stimmen"
        case federnbestimmung = "Federnbestimmung"
        case globaleSituationBirdLifeInternational = "Globale_Situation_BirdLife_International"
        case synonyme = "Synonyme"
        case chBestandPeriode = "CH_Bestand_Periode"
        case merkmale = "Merkmale"
        case autor0 = "autor_0"
        case bezeichnungDe0 = "bezeichnung_de_0"
        case autor1 = "autor_1"
        case bezeichnungDe1 = "bezeichnung_de_1"
        case autor2 = "autor_2"
        case bezeichnungDe2 = "bezeichnung_de_2"
        case filternahrung, filterlebensraum, filterhaeufigeart, filterrotelistech, filtervogelgruppe, filterentwicklungatlas, atlastext, literatur, atlasautor, bestand
        case bestandDatum = "bestand_datum"
        case entwicklung
        case atlasLebensraum = "atlas_lebensraum"
        case roteListe = "rote_liste"
        case partner1 = "partner_1"
        case partner2 = "partner_2"
        case partner3 = "partner_3"
        case partner4 = "partner_4"
        case partner5 = "partner_5"
        case density = "density"
        case densityChange = "density-change"
        case occupancy = "occupancy"
        case occupancyChange = "occupancy-change"
        case point = "point"
        case pointChange = "point-change"
        case distribution = "distribution"
        case record = "record"
        case migration = "migration"
        case winter = "winter"
        case water = "water"
        case index = "index"
        case indexMigrant = "index-migrant"
        case trendWater = "trend-water"
        case trendRecord = "trend-record"
        case phenology = "phenology"
        case phenologyRecord = "phenology-record"
        case altitude = "altitude"
        case altitudeChange = "altitude_change"
        case annualCycle = "annual-cycle"
        case alias = "alias"
        case uri = "uri"
        case uriDe = "uri_de"
        case uriFr = "uri_fr"
        case uriIt = "uri_it"
        case uriEn = "uri_en"
    }
}
