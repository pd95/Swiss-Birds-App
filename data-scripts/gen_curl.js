'use strict'

let filter = require(`./data/vds-filternames-de.json`);
filter.forEach(filter => {
    console.log(`curl --limit-rate 100K -#fo svg/download/${filter.type}-${filter.filterID}.svg https://www.vogelwarte.ch/elements/snippets/vds/static/assets/images/icons/filter/${filter.type}/${filter.filterID}.svg`);
})

let arten = require('./data/vds-list-de.json');
arten.forEach((a) => {
    console.log(`curl --limit-rate 100K -#fo data/species/${a.ArtId}-de.json https://www.vogelwarte.ch/elements/snippets/vds/static/assets/data/species/${a.ArtId}-de.json`);
    console.log(`curl --limit-rate 100K -#fo data/species/${a.ArtId}-fr.json https://www.vogelwarte.ch/elements/snippets/vds/static/assets/data/species/${a.ArtId}-fr.json`);
    console.log(`curl --limit-rate 100K -#fo data/species/${a.ArtId}-it.json https://www.vogelwarte.ch/elements/snippets/vds/static/assets/data/species/${a.ArtId}-it.json`);
    console.log(`curl --limit-rate 100K -#fo data/species/${a.ArtId}-en.json https://www.vogelwarte.ch/elements/snippets/vds/static/assets/data/species/${a.ArtId}-en.json`);
    console.log(`curl --limit-rate 100K -#fo images/headshots/${a.ArtId}@1x.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/headshots/80x80/${a.ArtId}@1x.jpg`);
    console.log(`curl --limit-rate 100K -#fo images/headshots/${a.ArtId}@2x.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/headshots/80x80/${a.ArtId}@2x.jpg`);
    console.log(`curl --limit-rate 100K -#fo images/headshots/${a.ArtId}@3x.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/headshots/80x80/${a.ArtId}@3x.jpg`);
    console.log(`curl --limit-rate 100K -#fo images/artbilder/${a.ArtId}_0.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/artbilder/700px/${a.ArtId.padStart(4, '0')}_0.jpg`);
    console.log(`curl --limit-rate 100K -#fo images/artbilder/${a.ArtId}_1.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/artbilder/700px/${a.ArtId.padStart(4, '0')}_1.jpg`);
    console.log(`curl --limit-rate 100K -#fo images/artbilder/${a.ArtId}_2.jpg https://www.vogelwarte.ch/assets/images/voegel/vds/artbilder/700px/${a.ArtId.padStart(4, '0')}_2.jpg`);
    console.log(`curl --limit-rate 100K -#fo voices/${a.ArtId}.mp3 https://www.vogelwarte.ch/assets/media/voices/${a.ArtId.padStart(4, '0')}.mp3`)
});
