//
//  VdsDataTypes.swift
//  Swiss-Birds
//
//  Created by Philipp on 01.06.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

struct VdsListElement: Codable {
    let artID, sysNr, artname, synonyme: String
    let alias, filterlebensraum, filtervogelgruppe, filternahrung: String
    let filterhaeufigeart, filterrotelistech: String
    let filterentwicklungatlas: String?
    let voice: String?

    enum CodingKeys: String, CodingKey {
        case artID = "artid"
        case sysNr = "sys_nr"
        case artname, synonyme, alias, filterlebensraum, filtervogelgruppe, filternahrung, filterhaeufigeart, filterrotelistech, filterentwicklungatlas, voice
    }
}

struct VdsFilter: Codable {
    let type, filterID, filterName: String
    enum CodingKeys: String, CodingKey {
        case type, filterID = "filter_id", filterName = "filter_name"
    }
}

struct VdsLabel: Codable {
    let labelID, label, desc: String
}

struct VdsSpecieDetail: Codable {
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

    internal init(artID: String, sysNr: String, artname: String, alternativName: String?, artnameLat: String?, infos: String?, roteListeCH: String?, zugverhalten: String?, laengeCM: String?, gewichtG: String?, gelegegroesse: String?, brutort: String?, brutdauerTage: String?, nestlingsdauerFlugfaehigkeitTage: String?, nahrung: String?, vogelgruppe: String?, lebensraum: String?, artnameFrz: String?, artnameItal: String?, artnameRr: String?, artnameEngl: String?, artnameSpan: String?, artnameHoll: String?, familieWiss: String?, familieDt: String?, spannweiteCM: String?, hoechstalterEURING: String?, hoechstalterCH: String?, jahresbruten: String?, statusInCH: String?, prioritaetsartArtenfoerderung: String?, videosBilderStimmen: String?, federnbestimmung: String?, globaleSituationBirdLifeInternational: String?, synonyme: String?, chBestandPeriode: String?, merkmale: String?, autor0: String?, bezeichnungDe0: String?, autor1: String?, bezeichnungDe1: String?, autor2: String?, bezeichnungDe2: String?, filternahrung: String?, filterlebensraum: String?, filterhaeufigeart: String?, filterrotelistech: String?, filtervogelgruppe: String?, filterentwicklungatlas: String?, atlastext: String?, literatur: String?, atlasautor: String?, bestand: String?, bestandDatum: String?, entwicklung: String?, atlasLebensraum: String?, roteListe: String?, partner1: String?, partner2: String?, partner3: String?, partner4: String?, partner5: String?, density: String?, densityChange: String?, occupancy: String?, occupancyChange: String?, point: String?, pointChange: String?, distribution: String?, record: String?, migration: String?, winter: String?, water: String?, index: String?, indexMigrant: String?, trendWater: String?, trendRecord: String?, phenology: String?, phenologyRecord: String?, altitude: String?, altitudeChange: String?, annualCycle: String?, alias: String?, uri: String?, uriDe: String?, uriFr: String?, uriIt: String?, uriEn: String?) {
        self.artID = artID
        self.sysNr = sysNr
        self.artname = artname
        self.alternativName = alternativName
        self.artnameLat = artnameLat
        self.infos = infos
        self.roteListeCH = roteListeCH
        self.zugverhalten = zugverhalten
        self.laengeCM = laengeCM
        self.gewichtG = gewichtG
        self.gelegegroesse = gelegegroesse
        self.brutort = brutort
        self.brutdauerTage = brutdauerTage
        self.nestlingsdauerFlugfaehigkeitTage = nestlingsdauerFlugfaehigkeitTage
        self.nahrung = nahrung
        self.vogelgruppe = vogelgruppe
        self.lebensraum = lebensraum
        self.artnameFrz = artnameFrz
        self.artnameItal = artnameItal
        self.artnameRr = artnameRr
        self.artnameEngl = artnameEngl
        self.artnameSpan = artnameSpan
        self.artnameHoll = artnameHoll
        self.familieWiss = familieWiss
        self.familieDt = familieDt
        self.spannweiteCM = spannweiteCM
        self.hoechstalterEURING = hoechstalterEURING
        self.hoechstalterCH = hoechstalterCH
        self.jahresbruten = jahresbruten
        self.statusInCH = statusInCH
        self.prioritaetsartArtenfoerderung = prioritaetsartArtenfoerderung
        self.videosBilderStimmen = videosBilderStimmen
        self.federnbestimmung = federnbestimmung
        self.globaleSituationBirdLifeInternational = globaleSituationBirdLifeInternational
        self.synonyme = synonyme
        self.chBestandPeriode = chBestandPeriode
        self.merkmale = merkmale
        self.autor0 = autor0
        self.bezeichnungDe0 = bezeichnungDe0
        self.autor1 = autor1
        self.bezeichnungDe1 = bezeichnungDe1
        self.autor2 = autor2
        self.bezeichnungDe2 = bezeichnungDe2
        self.filternahrung = filternahrung
        self.filterlebensraum = filterlebensraum
        self.filterhaeufigeart = filterhaeufigeart
        self.filterrotelistech = filterrotelistech
        self.filtervogelgruppe = filtervogelgruppe
        self.filterentwicklungatlas = filterentwicklungatlas
        self.atlastext = atlastext
        self.literatur = literatur
        self.atlasautor = atlasautor
        self.bestand = bestand
        self.bestandDatum = bestandDatum
        self.entwicklung = entwicklung
        self.atlasLebensraum = atlasLebensraum
        self.roteListe = roteListe
        self.partner1 = partner1
        self.partner2 = partner2
        self.partner3 = partner3
        self.partner4 = partner4
        self.partner5 = partner5
        self.density = density
        self.densityChange = densityChange
        self.occupancy = occupancy
        self.occupancyChange = occupancyChange
        self.point = point
        self.pointChange = pointChange
        self.distribution = distribution
        self.record = record
        self.migration = migration
        self.winter = winter
        self.water = water
        self.index = index
        self.indexMigrant = indexMigrant
        self.trendWater = trendWater
        self.trendRecord = trendRecord
        self.phenology = phenology
        self.phenologyRecord = phenologyRecord
        self.altitude = altitude
        self.altitudeChange = altitudeChange
        self.annualCycle = annualCycle
        self.alias = alias
        self.uri = uri
        self.uriDe = uriDe
        self.uriFr = uriFr
        self.uriIt = uriIt
        self.uriEn = uriEn
    }

    init(from species: VdsSpecieDetail_new) {
        let alias: String
        switch primaryLanguage {
        case "de":
            alias = species.aliasDe
        case "fr":
            alias = species.aliasFr
        case "it":
            alias = species.aliasIt
        default:
            alias = species.aliasEn
        }

        self = VdsSpecieDetail(
            artID: species.artid, sysNr: "", artname: species.artname, alternativName: species.artnamen.synonyme, artnameLat: species.artnamen.artnameLat, infos: species.infos,
            roteListeCH: species.bestand.roteListeCH, zugverhalten: species.eigenschaften.zugverhalten, laengeCM: species.eigenschaften.laengeCM,
            gewichtG: species.eigenschaften.gewichtG, gelegegroesse: species.eigenschaften.gelegegroesse, brutort: species.eigenschaften.brutort,
            brutdauerTage: species.eigenschaften.brutdauerTage, nestlingsdauerFlugfaehigkeitTage: species.eigenschaften.nestlingsdauerFlugfaehigkeitTage,
            nahrung: species.eigenschaften.nahrung, vogelgruppe: species.eigenschaften.vogelgruppe, lebensraum: species.eigenschaften.lebensraum,
            artnameFrz: species.artnamen.artnameFrz, artnameItal: species.artnamen.artnameItal, artnameRr: species.artnamen.artnameRr, artnameEngl: species.artnamen.artnameEngl,
            artnameSpan: species.artnamen.artnameSpan, artnameHoll: species.artnamen.artnameHoll, familieWiss: species.artnamen.familieWiss, familieDt: species.artnamen.artnameDe,
            spannweiteCM: species.eigenschaften.spannweiteCM, hoechstalterEURING: species.eigenschaften.hoechstalterEURING, hoechstalterCH: species.eigenschaften.hoechstalterCH,
            jahresbruten: species.eigenschaften.jahresbruten, statusInCH: species.statusInCH, prioritaetsartArtenfoerderung: species.bestand.prioritaetsartArtenfoerderung,
            videosBilderStimmen: species.voice, federnbestimmung: nil, globaleSituationBirdLifeInternational: nil, synonyme: nil, chBestandPeriode: nil, merkmale: nil,
            autor0: species.artbilder.count > 0 ? species.artbilder[0].autor : nil,
            bezeichnungDe0: species.artbilder.count > 0 ? species.artbilder[0].bezeichnung : nil,
            autor1: species.artbilder.count > 1 ? species.artbilder[1].autor : nil,
            bezeichnungDe1: species.artbilder.count > 1 ? species.artbilder[1].bezeichnung : nil,
            autor2: species.artbilder.count > 2 ? species.artbilder[2].autor : nil,
            bezeichnungDe2: species.artbilder.count > 2 ? species.artbilder[2].bezeichnung : nil,
            filternahrung: species.filternahrung, filterlebensraum: species.filterlebensraum, filterhaeufigeart: species.filterhaeufigeart, filterrotelistech: species.filterrotelistech,
            filtervogelgruppe: species.filtervogelgruppe, filterentwicklungatlas: species.filterentwicklungatlas,
            atlastext: species.atlastext, literatur: species.atlasLiteratur, atlasautor: species.atlasAutor, bestand: species.bestand.atlasBestand,
            bestandDatum: species.bestand.atlasBestandDatum, entwicklung: species.atlasEntwicklung,
            atlasLebensraum: nil, roteListe: nil, partner1: nil, partner2: nil, partner3: nil, partner4: nil, partner5: nil, density: nil, densityChange: nil, occupancy: nil,
            occupancyChange: nil, point: nil, pointChange: nil, distribution: nil, record: nil, migration: nil, winter: nil, water: nil, index: nil, indexMigrant: nil,
            trendWater: nil, trendRecord: nil, phenology: nil, phenologyRecord: nil, altitude: nil, altitudeChange: nil, annualCycle: nil, alias: alias,
            uri: nil, uriDe: nil, uriFr: nil, uriIt: nil, uriEn: nil
        )
    }
}

struct VdsSpecieDetail_new: Codable {
    let artid, artname, infos, merkmale: String
    let eigenschaften: Eigenschaften
    let artnamen: Artnamen
    let voice: String
    let artbilder: [Artbilder]
    let bestand: Bestand
    let statusInCH, filternahrung, filterlebensraum, filterhaeufigeart: String
    let filterrotelistech, filtervogelgruppe, filterentwicklungatlas, atlastext: String
    let atlasLiteratur, atlasAutor, atlasEntwicklung: String
    let maps, charts: [String]
    let aliasDe, aliasFr, aliasIt, aliasEn: String

    enum CodingKeys: String, CodingKey {
        case artid, artname, infos, merkmale, eigenschaften, artnamen, voice, artbilder, bestand
        case statusInCH = "status_in_ch"
        case filternahrung, filterlebensraum, filterhaeufigeart, filterrotelistech, filtervogelgruppe, filterentwicklungatlas, atlastext
        case atlasLiteratur = "atlas_literatur"
        case atlasAutor = "atlas_autor"
        case atlasEntwicklung = "atlas_entwicklung"
        case maps, charts
        case aliasDe = "alias_de"
        case aliasFr = "alias_fr"
        case aliasIt = "alias_it"
        case aliasEn = "alias_en"
    }

    struct Artbilder: Codable {
        let autor, bezeichnung: String
    }

    struct Artnamen: Codable {
        let artnameDe, artnameLat, artnameFrz, artnameItal: String
        let artnameRr, artnameEngl, artnameSpan, artnameHoll: String
        let familieWiss, synonyme: String

        enum CodingKeys: String, CodingKey {
            case artnameDe = "artname_de"
            case artnameLat = "artname_lat"
            case artnameFrz = "artname_frz"
            case artnameItal = "artname_ital"
            case artnameRr = "artname_rr"
            case artnameEngl = "artname_engl"
            case artnameSpan = "artname_span"
            case artnameHoll = "artname_holl"
            case familieWiss = "familie_wiss"
            case synonyme
        }
    }

    struct Bestand: Codable {
        let atlasBestand, atlasBestandDatum, roteListeCH, prioritaetsartArtenfoerderung: String

        enum CodingKeys: String, CodingKey {
            case atlasBestand = "atlas_bestand"
            case atlasBestandDatum = "atlas_bestand_datum"
            case roteListeCH = "rote_liste_ch"
            case prioritaetsartArtenfoerderung = "prioritaetsart_artenfoerderung"
        }
    }

    struct Eigenschaften: Codable {
        let vogelgruppe, laengeCM, spannweiteCM, gewichtG: String
        let nahrung, lebensraum, zugverhalten, brutort: String
        let brutdauerTage, jahresbruten, gelegegroesse, nestlingsdauerFlugfaehigkeitTage: String
        let hoechstalterEURING, hoechstalterCH: String

        enum CodingKeys: String, CodingKey {
            case vogelgruppe
            case laengeCM = "laenge_cm"
            case spannweiteCM = "spannweite_cm"
            case gewichtG = "gewicht_g"
            case nahrung, lebensraum, zugverhalten, brutort
            case brutdauerTage = "brutdauer_tage"
            case jahresbruten, gelegegroesse
            case nestlingsdauerFlugfaehigkeitTage = "nestlingsdauer_flugfaehigkeit_tage"
            case hoechstalterEURING = "hoechstalter_euring"
            case hoechstalterCH = "hoechstalter_ch"
        }
    }
}
