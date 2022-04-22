'use strict'

const fs = require('fs');

let types = ['filters', 'list'];
let languages = ['de', 'en', 'fr', 'it'];

types.forEach(element => {
    languages.forEach(language => {
        console.log(element, language)
        let result = []
        let signatures = new Set()
        let filename = `./data/${element}_${language}.json`
        if (fs.existsSync(filename) == false) {
            console.log(`File ${filename} does not exist.`)
            return
        }
        let rawdata = fs.readFileSync(filename);
        if (rawdata.length == 0) {
            console.log(`File ${filename} is empty.`)
            return
        }
        let data = JSON.parse(rawdata);
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
            fs.writeFileSync(filename, jsonContent, 'utf8')
            console.log(`File ${filename} written`)
        }
    })
});
