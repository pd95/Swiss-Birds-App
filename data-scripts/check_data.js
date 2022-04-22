'use_strict'

// This script checks all JSON species detail to produce a JSON response template with all possible keys and empty fields
// which can then be used for JSON parser creation.

let allKeys = {};
const emptyStats = {
    occurrence: 0,
    empty: 0
};

let speciesTemplate = {};

function checkFields(object, prefix, postfix, templateObject) {
    Object.keys(object).forEach(key => {

        if (object[key].constructor == Object) {
            templateObject[key] = {}
            checkFields(object[key], prefix+key+"_", postfix, templateObject[key])
        } else if (object[key].constructor == Array && object[key].length > 0 && object[key][0].constructor == Object) {
            templateObject[key] = []
            object[key].forEach((object, index) => {
                templateObject[key][index] = {};
                checkFields(object, prefix+key+"_"+index+"_", postfix, templateObject[key][index])
            })
        } else {
            let statsKey = prefix+key+postfix
            let value = object[key]
            let isEmpty = value.length == 0

            if (!templateObject[key]) {
                templateObject[key] = value.length > 20 ? value.substr(0, 19)+"..." : value
            } else if (isEmpty) {
                templateObject[key] = ""
            }

            let currentStats = allKeys[statsKey]
            if (!currentStats) {
                currentStats = {}
                Object.assign(currentStats, emptyStats)
                currentStats.values = {}
            }
            currentStats.occurrence += 1
            currentStats.empty += (isEmpty ? 1 : 0)

            if (prefix == "eigenschaften_" ||
                prefix == "bestand_" ||
                key == "maps" ||
                key == "charts" ||
                key == "status_in_ch" ||
                key.substr(0,6) == "filter"
            ) {
                let existingValueCount = currentStats.values[value] | 0
                currentStats.values[value] = existingValueCount + 1
            }
    
            allKeys[statsKey] = currentStats
        }
    });
}

["de" /*, "en", "fr", "it"*/].forEach((language) => {
    let species = require(`./data/list_de.json`);
    species.forEach((a) => {
        console.log(`${language} ${a.artid} ${a.artname}`)
        let details = require(`./data/species/${a.artid}_${language}.json`)
    
        checkFields(details, "", "", speciesTemplate) //"_"+language)
        //console.log(Object.keys(details))
    })    
})

console.log(allKeys)
console.log(speciesTemplate)

console.log(JSON.stringify(speciesTemplate, null, 2))
Object.keys(allKeys).forEach((key) => {
    let entry = allKeys[key]
    if (Object.keys(entry.values).length > 0) {
        console.log(key, entry.values)
    }
})
debugger
