'use strict'

const fs = require('fs');

let types = ['filters'];
let languages = ['de'];

types.forEach(element => {
    languages.forEach(language => {
        console.log(element, language)
        let result = []
        let signatures = new Set()
        let data = require(`./data/${element}_${language}.json`);
        if (data instanceof Array) {
            // get rid of duplicate entries
            data.forEach(obj => {
                let signature = obj['artid'] || obj['type'] + obj['filter_id'];
                if (!signature) {
                    console.log('Signature not available', obj)
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
            let filename = `./data/${element}_${language}.json`
            fs.writeFile(filename, jsonContent, 'utf8', function (err) {
                if (err) {
                    console.log(`An error occurred while writing JSON Object to File ${filename}`);
                    return console.log(err);
                }
                console.log(`File ${filename} written`)
            });
        }
    })
});
