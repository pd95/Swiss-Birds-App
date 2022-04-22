//
//  RemoteDataMapper.swift
//  SpeciesCore
//
//  Created by Philipp on 16.04.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation

public enum RemoteDataMapper {

    enum Errors: Error {
        case invalidID(String)
    }

    public static func mapFilter(_ data: Data) throws -> FilterCollection {
        let filter = try JSONDecoder()
            .decode([FilterDTO].self, from: data)
            .map({ rawFilter in
                guard let filterID = Int(rawFilter.filterID) else {
                    throw Errors.invalidID(rawFilter.filterID)
                }
                return (type: FilterType(rawFilter.type), id: filterID, name: rawFilter.filterName)
            })
            .reduce(into: FilterCollection(), { (filters: inout FilterCollection, filter: (type: FilterType, id: Int, name: String)) in
                filters.addFilter(type: filter.type, id: filter.id, name: filter.name)
            })
        return filter
    }

    public static func mapSpecies(_ data: Data) throws -> [Species] {
        let species = try JSONDecoder()
            .decode([SpeciesDTO].self, from: data)
            .map({ raw -> Species in
                guard let speciesID = Int(raw.id) else {
                    throw Errors.invalidID(raw.id)
                }

                let filters = mapSpeciesFilters(raw.filters)

                return Species(id: speciesID, name: raw.name, synonyms: raw.synonyms, alias: raw.alias, voiceData: raw.voiceData == "1", filters: filters)
            })
        return species
    }

    public static func mapSpeciesDetail(_ data: Data, language: String) throws -> SpeciesDetail {

        let decoder = JSONDecoder()
        let dto = try decoder.decode(SpeciesDetailDTO.self, from: data)

        guard let speciesID = Int(dto.id) else {
            throw Errors.invalidID(dto.id)
        }

        let speciesNames = mapSpeciesNames(dto)
        let alias = mapSpeciesAliases(dto)

        let filtersDTO = try decoder.decode(SpeciesDetailDTO.SpeciesFilter.self, from: data)
        let filters = mapSpeciesFilters(filtersDTO.filters)

        var priorityInRecoveryPrograms: Bool?
        if dto.population.priorityInRecoveryPrograms.isEmpty == false {
            let value = Int(dto.population.priorityInRecoveryPrograms) ?? 0
            priorityInRecoveryPrograms = value > 0
        }

        let details = SpeciesDetail(
            id: speciesID,
            name: dto.name,
            facts: dto.facts,
            identificationCriteria: dto.identificationCriteria,
            group: dto.properties.group,
            length: dto.properties.length,
            weight: dto.properties.weight,
            wingSpan: dto.properties.wingSpan,
            food: dto.properties.food,
            habitat: dto.properties.habitat,
            clutchSize: dto.properties.clutchSize,
            nestSite: dto.properties.nestSite,
            incubation: dto.properties.incubation,
            nestlingStage: dto.properties.nestlingStage,
            broodsPerYear: dto.properties.broodsPerYear,
            migrationBehavior: dto.properties.migrationBehavior,
            maximumAgeEURING: dto.properties.maximumAgeEURING,
            maximumAgeCH: dto.properties.maximumAgeCH,
            redListCH: dto.population.redListCH,
            statusInCH: dto.statusInCH,
            priorityInRecoveryPrograms: priorityInRecoveryPrograms,
            synonyms: dto.speciesNames.synonyms,
            scientificName: dto.speciesNames.scientificName,
            scientificFamily: dto.speciesNames.scientificFamily,
            speciesNames: speciesNames,
            alias: alias,
            filters: filters
        )
        return details
    }


    private static func mapSpeciesFilters(_ rawFilters: [(type: String, filterIDs: String)]) -> Set<Filter> {
        var filters = Set<Filter>()
        for (type, filterIDsString) in rawFilters {
            let filterIDs = filterIDsString.split(separator: ",").compactMap({ Int($0) })
            for id in filterIDs {
                filters.insert(Filter(type: FilterType(type), id: id, name: nil))
            }
        }
        return filters
    }

    private static func mapSpeciesNames(_ details: SpeciesDetailDTO) -> [NameLanguage: String] {
        var speciesNames = [NameLanguage: String]()

        speciesNames[.german] = details.speciesNames.name_de
        speciesNames[.french] = details.speciesNames.name_fr
        speciesNames[.italian] = details.speciesNames.name_it
        speciesNames[.rhaetoRoman] = details.speciesNames.name_rr
        speciesNames[.english] = details.speciesNames.name_en
        speciesNames[.spanish] = details.speciesNames.name_sp
        speciesNames[.dutch] = details.speciesNames.name_ho

        return speciesNames.filter({ $0.value.isEmpty == false })
    }

    private static func mapSpeciesAliases(_ details: SpeciesDetailDTO) -> [NameLanguage: String] {
        var alias = [NameLanguage: String]()
        alias[.german] = details.alias_de
        alias[.french] = details.alias_fr
        alias[.italian] = details.alias_it
        alias[.english] = details.alias_en

        return alias.filter({ $0.value.isEmpty == false })
    }
}
