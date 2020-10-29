'use strict'

let filter = require(`./data/filters_de.json`);
filter.forEach(filter => {
    let filename = `${filter.type}-${filter.filter_id}.svg`
    if (filter.type === "filterentwicklungatlas") {
        console.log(`cp filterentwicklungatlas/${filename} svg/download/${filename}`);
    }
    else {
        console.log(`curl --limit-rate 100K -#fo svg/download/${filename} https://www.vogelwarte.ch/elements/snippets/vds/static/assets/images/icons_new/filter/${filter.type}/${filter.filter_id}.svg`);
    }
})
