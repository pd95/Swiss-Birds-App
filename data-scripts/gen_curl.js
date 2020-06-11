'use strict'

let filter = require(`./data/vds-filternames-de.json`);
filter.forEach(filter => {
    console.log(`curl --limit-rate 100K -#fo svg/download/${filter.type}-${filter.filterID}.svg https://www.vogelwarte.ch/elements/snippets/vds/static/assets/images/icons/filter/${filter.type}/${filter.filterID}.svg`);
})
