import usFlag from '../../../../../public/static/country-flag/us.svg'
import arFlag from '../../../../../public/static/country-flag/arabic-flag-svg.svg'
import banFlag from '../../../../../public/static/country-flag/bangladesh (1).png'
import spanFlag from '../../../../../public/static/country-flag/spain.png'
import frFlag from '../../../../../public/static/country-flag/france.svg'
export const languageLists = [
    {
        languageName: 'Français',
        languageCode: 'fr',
        countryCode: 'FR',
        countryFlag: frFlag.src,
    },
    {
        languageName: 'English',
        languageCode: 'en',
        countryCode: 'US',
        countryFlag: usFlag.src,
    },
    {
        languageName: 'Arabic',
        languageCode: 'ar',
        countryCode: 'SA',
        countryFlag: arFlag.src,
    },
    {
        languageName: 'Spanish',
        languageCode: 'es',
        countryCode: 'es',
        countryFlag: spanFlag.src,
    },
    {
        languageName: 'Bengali',
        languageCode: 'bn',
        countryCode: 'BN',
        countryFlag: banFlag.src,
    },
]
