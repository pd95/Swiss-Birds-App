'use strict'

let fetchFilterSVG = true
let fetchDetails = false
let fetchMedia = false

let staticAssetsURL = "https://www.vogelwarte.ch/elements/snippets/vds/static/assets"
let speciesImagesURL = "https://www.vogelwarte.ch/assets/images/voegel/vds"
let speciesVoiceURL = "https://www.vogelwarte.ch/assets/media/voices"

if (fetchFilterSVG) {
    let filter = require(`./data/filters_de.json`);
    filter.forEach(filter => {
        let filename = `${filter.type}-${filter.filter_id}.svg`
        if (filter.type === "filterentwicklungatlas") {
            console.log(`cp filterentwicklungatlas/${filename} svg/download/${filename}`);
        }
        else {
            console.log(`curl --limit-rate 100K -#fo svg/download/${filename} ${staticAssetsURL}/images/icons_new/filter/${filter.type}/${filter.filter_id}.svg`);
        }
    })    
}

if (fetchDetails) {
    let species = require('./data/list_de.json');
    console.log(`mkdir -p data/species`);
    species.forEach((species) => {
        console.log(`curl --limit-rate 100K -#fo data/species/${species.artid}_de.json ${staticAssetsURL}/data/species/${species.artid}_de.json`);
        console.log(`curl --limit-rate 100K -#fo data/species/${species.artid}_fr.json ${staticAssetsURL}/data/species/${species.artid}_fr.json`);
        console.log(`curl --limit-rate 100K -#fo data/species/${species.artid}_it.json ${staticAssetsURL}/data/species/${species.artid}_it.json`);
        console.log(`curl --limit-rate 100K -#fo data/species/${species.artid}_en.json ${staticAssetsURL}/data/species/${species.artid}_en.json`);
    });
}

if (fetchMedia) {
    let species = require('./data/list_de.json');
    console.log(`mkdir -p images/headshots`);
    console.log(`mkdir -p images/artbilder`);
    console.log(`mkdir -p voices`);
    species.forEach((species) => {
        console.log(`curl --limit-rate 100K -#fo images/headshots/${species.artid}@1x.jpg ${speciesImagesURL}/headshots/80x80/${species.artid}@1x.jpg`);
        console.log(`curl --limit-rate 100K -#fo images/headshots/${species.artid}@2x.jpg ${speciesImagesURL}/headshots/80x80/${species.artid}@2x.jpg`);
        console.log(`curl --limit-rate 100K -#fo images/headshots/${species.artid}@3x.jpg ${speciesImagesURL}/headshots/80x80/${species.artid}@3x.jpg`);
        console.log(`curl --limit-rate 100K -#fo images/artbilder/${species.artid}_0.jpg ${speciesImagesURL}/artbilder/700px/${species.artid.padStart(4, '0')}_0.jpg`);
        console.log(`curl --limit-rate 100K -#fo images/artbilder/${species.artid}_1.jpg ${speciesImagesURL}/artbilder/700px/${species.artid.padStart(4, '0')}_1.jpg`);
        console.log(`curl --limit-rate 100K -#fo images/artbilder/${species.artid}_2.jpg ${speciesImagesURL}/artbilder/700px/${species.artid.padStart(4, '0')}_2.jpg`);
        if (species.voice == "1") {
            console.log(`curl --limit-rate 100K -#fo voices/${species.artid}.mp3 ${speciesVoiceURL}/${species.artid.padStart(4, '0')}.mp3`)
        }
    });
}
