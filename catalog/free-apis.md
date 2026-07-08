# Free / public APIs

Schema (one entry per line, pipe-delimited, grep-friendly):
`name | type | tags | description | access | url`
- type: api | api-directory
- access: none (no key) | key | oauth | free-tier | paid
Check each provider's terms and rate limits before relying on it.

## Directories (start here for breadth)

APIs.guru | api-directory | openapi discovery machine-readable spec | 2500+ APIs as OpenAPI specs, no-auth REST index | none | https://apis.guru
public-apis | api-directory | index catalog free curated | huge community list, entries.json for bulk | none | https://github.com/public-apis/public-apis
public-api-lists | api-directory | index catalog json | 730+ APIs, /api/all.json bulk, CORS/key metadata | none | https://github.com/public-apis/public-api-lists
freepublicapis | api-directory | uptime reliability monitored | catalog health-checked every 4h | none | https://www.freepublicapis.com
Postman Public API Network | api-directory | collections search | vast searchable public API taxonomy | none | https://www.postman.com/explore

## Dev, security, infrastructure

GitHub REST API | api | git repos issues pull-requests ci code | manage repos/PRs/issues/orgs | oauth | https://docs.github.com/rest
GitLab API | api | git ci-cd repos pipelines | automate GitLab repos and pipelines | oauth | https://docs.gitlab.com/ee/api
Bitbucket API | api | git repos pull-requests source-control | repo management and PRs | oauth | https://developer.atlassian.com/bitbucket
IPstack | api | ip geolocation network | locate visitors by IP | key | https://ipstack.com
IP-API | api | ip geolocation network | IP geolocation, free tier | none | https://ip-api.com
BrowserCat | api | headless-browser scraping automation testing | headless browser automation | key | https://www.browsercat.com
VirusTotal | api | malware threat security files urls | analyze files/domains/IPs/URLs for malware | key | https://developers.virustotal.com
Google Safe Browsing | api | security phishing malware urls | check URLs against unsafe lists | key | https://developers.google.com/safe-browsing
URLhaus | api | malware urls threat-intel | query/download malicious URL data | none | https://urlhaus.abuse.ch/api
URLScan.io | api | url scan reputation security | scan and snapshot URLs | key | https://urlscan.io/docs/api
CAPEsandbox | api | malware sandbox behavioral-analysis | detonate files for behavior analysis | key | https://capev2.readthedocs.io
AlienVault OTX | api | threat-intel reputation security | threat feeds, IP/domain reputation | key | https://otx.alienvault.com
MalShare | api | malware datasets threat-intel | malware sample sourcing | key | https://malshare.com
Mailboxlayer | api | email validation verification | validate/verify emails | key | https://mailboxlayer.com
Mailgun | api | email sending routing templating | transactional email | key | https://www.mailgun.com
Mailjet | api | email sending tracking | transactional email + tracking | key | https://www.mailjet.com
Screenshotlayer | api | screenshot rendering capture | website screenshots via GET | key | https://screenshotlayer.com
Filestack | api | file upload transform delivery | upload/transform/deliver files | key | https://www.filestack.com
DigitalOcean Status | api | status uptime cloud monitoring | real-time DO service status | none | https://status.digitalocean.com
isitdown / DownStatus | api | status uptime monitoring cloud | status of GitHub/AWS/Discord/Stripe/90+ | none | https://isitdown.site
CORSfix | api | cors proxy fetch browser | bypass client-side CORS in testing | none | https://corsfix.com

## Finance, market, economic

Fixer.io | api | forex currency exchange-rates | FX rates, 170 currencies (ECB) | key | https://fixer.io
Alpha Vantage | api | stocks forex crypto indicators market | real-time+historical market data | key | https://www.alphavantage.co
Marketstack | api | stocks market historical | worldwide stock market data | key | https://marketstack.com
Exchangerate-API | api | forex currency conversion | exchange rates + conversion | key | https://www.exchangerate-api.com
Open Exchange Rates | api | forex currency historical | exchange rates + conversion | key | https://openexchangerates.org
CurrencyLayer | api | forex currency precious-metals | exchange rates incl. metals | key | https://currencylayer.com
Exchangerate.host | api | forex currency crypto | FX + crypto rates | key | https://exchangerate.host
Frankfurter | api | forex currency exchange-rates | FX rates, no key | none | https://www.frankfurter.app
CoinGecko | api | crypto prices market | crypto prices, free tier | none | https://www.coingecko.com/en/api

## Weather, geo, environment

National Weather Service | api | weather forecast alerts gov geo | US forecasts/alerts, no key (User-Agent) | none | https://www.weather.gov/documentation/services-web-api
Open-Meteo | api | weather forecast climate geo | high-res forecasts, no key | none | https://open-meteo.com
OpenWeatherMap | api | weather forecast precipitation alerts | global weather data | key | https://openweathermap.org/api
Weatherstack | api | weather forecast | real-time + 14-day forecasts | key | https://weatherstack.com
AccuWeather | api | weather forecast air-quality pollen | hyperlocal forecasts, AQI, pollen | key | https://developer.accuweather.com
Weatherbit | api | weather forecast ml | ML-corrected 16-day forecasts | key | https://www.weatherbit.io
Meteoblue | api | weather forecast history visual | weather params + history | key | https://www.meteoblue.com
Visual Crossing | api | weather history climatology | weather + historical climate | key | https://www.visualcrossing.com
Nominatim (OSM) | api | geocoding places maps geo | geocoding, no key (usage policy) | none | https://nominatim.org
REST Countries | api | countries geo reference | country data, no key | none | https://restcountries.com

## AI / ML

Hugging Face Inference | api | ml models nlp vision audio inference | thousands of pretrained models | key | https://huggingface.co/docs/api-inference
OpenAI API | api | llm text generation embeddings | text gen, function calling | key | https://platform.openai.com/docs
Google Cloud Vision | api | vision ocr image detection translate | image recognition, OCR | key | https://cloud.google.com/vision
IBM Watson | api | nlp chatbot sentiment assistant | NLU + assistant | key | https://cloud.ibm.com/apidocs
OpenML | api | datasets ml experiments | shared datasets/algorithms | key | https://www.openml.org/apis
Anthropic | api | llm claude text agents | Claude API (house model) | key | https://docs.claude.com
Google Gemini | api | llm gemini text vision | Gemini API, free tier | key | https://ai.google.dev

## Utility, files, communications

Aviationstack | api | aviation flights tracking realtime | real-time flight status | key | https://aviationstack.com
Zenserp | api | search serp seo scraping | Google search results parsing | key | https://zenserp.com
Numverify | api | phone validation carrier | phone number validation | key | https://numverify.com
Genderize.io | api | name gender inference | gender from first name, no key | none | https://genderize.io
GoQR | api | qr barcode generate decode | QR code generate/read | none | https://goqr.me/api
ExtendsClass | api | mock json-store prototyping | temp JSON store / mocks | none | https://extendsclass.com/json-storage.html
emptychair.dev | api | text hashing json regex utility | dev utilities (hash/regex/format) | none | https://emptychair.dev
LogoKit | api | logo brand images | brand/stock/crypto logos | key | https://logokit.com
Fontsource | api | fonts google-fonts download | discover/self-host web fonts | none | https://fontsource.org
HTTP2.Pro | api | http2 protocol test | HTTP/2 support verification | none | https://http2.pro
JSONPlaceholder | api | fake-data testing rest mock | fake REST data for tests | none | https://jsonplaceholder.typicode.com

## Social, media, reference

AdoptAPet | api | pets shelters animals | shelter/adoption data | key | https://www.adoptapet.com/public/apis/pet_list.html
Europeana | api | museum library culture heritage | European cultural digital content | key | https://pro.europeana.eu/page/apis
Behance | api | design portfolio creative | design portfolios/projects | key | https://www.behance.net/dev
Dribbble | api | design shots portfolio creative | design shots/profiles | oauth | https://developer.dribbble.com
Cooper Hewitt | api | museum design smithsonian collection | Smithsonian Design Museum collection | key | https://collection.cooperhewitt.org/api
Wikipedia / Wikimedia REST | api | encyclopedia articles reference | articles/summaries | none | https://api.wikimedia.org
Open Library | api | books metadata reference | book metadata, no key | none | https://openlibrary.org/developers/api
