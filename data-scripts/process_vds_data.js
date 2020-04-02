'use strict'

const fs = require('fs');

let types = ['list', 'labels', 'filternames'];
let languages = ['de', 'fr', 'it', 'en'];

types.forEach(element => {
    languages.forEach(language => {
        console.log(element, language)
        let result = []
        let signatures = new Set()
        let data = require(`./data/vds-${element}-${language}.json`);
        if (data instanceof Array) {
            // get rid of duplicate entries
            data.forEach(obj => {
                let signature = obj['ArtId'] || obj['labelID'] || obj['type'] + obj['filterID'];
                if (!signature) {
                    console.log('ArtId not available', obj)
                }
                if (!signatures.has(signature)) {
                    signatures.add(signature)
                    result.push(obj)
                }
                else {
                    console.log('skipping duplicate ', obj)
                }
            })
            let jsonContent = JSON.stringify(result);
            let filename = `./data/vds-${element}-${language}.json`
            fs.writeFile(filename, jsonContent, 'utf8', function (err) {
                if (err) {
                    console.log(`An error occured while writing JSON Object to File ${filename}`);
                    return console.log(err);
                }
                console.log(`File ${filename} written`)
            });
        }
    })
});
