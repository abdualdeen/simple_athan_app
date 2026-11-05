/// Abbreviates the state and country parts of a `city, state, country`
/// location display name where a well-known short form exists.
///
/// For example:
/// - `Portland, Oregon, United States` becomes `Portland, OR, US`
/// - `Toronto, Ontario, Canada` becomes `Toronto, ON, CA`
/// - `London, United Kingdom` becomes `London, UK`
///
/// The city part is never touched, and segments without a common short form
/// are left alone, so `Paris, Île-de-France, France` only loses the country
/// suffix. A segment is only treated as a state when the country is one whose
/// subdivisions have standard abbreviations, which keeps place names like
/// `Victoria, Seychelles` intact.
String abbreviateLocationName(String name) {
  final List<String> segments = name
      .split(',')
      .map((String part) => part.trim())
      .where((String part) => part.isNotEmpty)
      .toList();
  if (segments.length < 2) return name;

  final String country = segments.last;
  final String? countryCode = _countryCodes[country.toLowerCase()];

  if (countryCode != null) {
    segments[segments.length - 1] = countryCode;
    // States only sit before the country, never in a two-part name.
    if (segments.length >= 3) {
      final Map<String, String>? subdivisions = _subdivisions[countryCode];
      final String? code =
          subdivisions?[segments[segments.length - 2].toLowerCase()];
      if (code != null) segments[segments.length - 2] = code;
    }
    return segments.join(', ');
  }

  // Without a country match, a two-part name may end in a state, such as
  // `Portland, Oregon` from a placemark with no country.
  if (segments.length == 2) {
    for (final Map<String, String> subdivisions in _subdivisions.values) {
      final String? code = subdivisions[country.toLowerCase()];
      if (code != null) {
        segments[1] = code;
        break;
      }
    }
  }
  return segments.join(', ');
}

/// English country names as returned by the platform geocoder, keyed for
/// case-insensitive lookup. Countries missing here degrade gracefully and
/// keep their full name.
const Map<String, String> _countryCodes = <String, String>{
  'afghanistan': 'AF',
  'albania': 'AL',
  'algeria': 'DZ',
  'andorra': 'AD',
  'angola': 'AO',
  'argentina': 'AR',
  'armenia': 'AM',
  'australia': 'AU',
  'austria': 'AT',
  'azerbaijan': 'AZ',
  'bahamas': 'BS',
  'bahrain': 'BH',
  'bangladesh': 'BD',
  'barbados': 'BB',
  'belarus': 'BY',
  'belgium': 'BE',
  'belize': 'BZ',
  'benin': 'BJ',
  'bhutan': 'BT',
  'bolivia': 'BO',
  'bosnia and herzegovina': 'BA',
  'botswana': 'BW',
  'brazil': 'BR',
  'brunei': 'BN',
  'bulgaria': 'BG',
  'burkina faso': 'BF',
  'burundi': 'BI',
  'cambodia': 'KH',
  'cameroon': 'CM',
  'canada': 'CA',
  'chad': 'TD',
  'chile': 'CL',
  'china': 'CN',
  'colombia': 'CO',
  'costa rica': 'CR',
  'croatia': 'HR',
  'cuba': 'CU',
  'cyprus': 'CY',
  'czechia': 'CZ',
  'czech republic': 'CZ',
  'denmark': 'DK',
  'djibouti': 'DJ',
  'dominica': 'DM',
  'dominican republic': 'DO',
  'ecuador': 'EC',
  'egypt': 'EG',
  'el salvador': 'SV',
  'eritrea': 'ER',
  'estonia': 'EE',
  'eswatini': 'SZ',
  'ethiopia': 'ET',
  'fiji': 'FJ',
  'finland': 'FI',
  'france': 'FR',
  'gambia': 'GM',
  'georgia': 'GE',
  'germany': 'DE',
  'ghana': 'GH',
  'greece': 'GR',
  'grenada': 'GD',
  'guatemala': 'GT',
  'guinea': 'GN',
  'guyana': 'GY',
  'haiti': 'HT',
  'honduras': 'HN',
  'hong kong': 'HK',
  'hungary': 'HU',
  'iceland': 'IS',
  'india': 'IN',
  'indonesia': 'ID',
  'iran': 'IR',
  'iraq': 'IQ',
  'ireland': 'IE',
  'israel': 'IL',
  'italy': 'IT',
  'ivory coast': 'CI',
  'jamaica': 'JM',
  'japan': 'JP',
  'jordan': 'JO',
  'kazakhstan': 'KZ',
  'kenya': 'KE',
  'kuwait': 'KW',
  'kyrgyzstan': 'KG',
  'laos': 'LA',
  'latvia': 'LV',
  'lebanon': 'LB',
  'liberia': 'LR',
  'libya': 'LY',
  'liechtenstein': 'LI',
  'lithuania': 'LT',
  'luxembourg': 'LU',
  'macau': 'MO',
  'madagascar': 'MG',
  'malawi': 'MW',
  'malaysia': 'MY',
  'maldives': 'MV',
  'mali': 'ML',
  'malta': 'MT',
  'mauritania': 'MR',
  'mauritius': 'MU',
  'mexico': 'MX',
  'moldova': 'MD',
  'monaco': 'MC',
  'mongolia': 'MN',
  'montenegro': 'ME',
  'morocco': 'MA',
  'mozambique': 'MZ',
  'myanmar': 'MM',
  'namibia': 'NA',
  'nepal': 'NP',
  'netherlands': 'NL',
  'new zealand': 'NZ',
  'nicaragua': 'NI',
  'niger': 'NE',
  'nigeria': 'NG',
  'north korea': 'KP',
  'north macedonia': 'MK',
  'norway': 'NO',
  'oman': 'OM',
  'pakistan': 'PK',
  'palestine': 'PS',
  'panama': 'PA',
  'papua new guinea': 'PG',
  'paraguay': 'PY',
  'peru': 'PE',
  'philippines': 'PH',
  'poland': 'PL',
  'portugal': 'PT',
  'puerto rico': 'PR',
  'qatar': 'QA',
  'romania': 'RO',
  'russia': 'RU',
  'russian federation': 'RU',
  'rwanda': 'RW',
  'saudi arabia': 'SA',
  'senegal': 'SN',
  'serbia': 'RS',
  'sierra leone': 'SL',
  'singapore': 'SG',
  'slovakia': 'SK',
  'slovenia': 'SI',
  'somalia': 'SO',
  'south africa': 'ZA',
  'south korea': 'KR',
  'spain': 'ES',
  'sri lanka': 'LK',
  'sudan': 'SD',
  'suriname': 'SR',
  'seychelles': 'SC',
  'sweden': 'SE',
  'switzerland': 'CH',
  'syria': 'SY',
  'taiwan': 'TW',
  'tajikistan': 'TJ',
  'tanzania': 'TZ',
  'thailand': 'TH',
  'togo': 'TG',
  'trinidad and tobago': 'TT',
  'tunisia': 'TN',
  'turkey': 'TR',
  'türkiye': 'TR',
  'turkmenistan': 'TM',
  'uganda': 'UG',
  'ukraine': 'UA',
  'united arab emirates': 'AE',
  'united kingdom': 'UK',
  'great britain': 'GB',
  'united states': 'US',
  'united states of america': 'US',
  'usa': 'US',
  'uruguay': 'UY',
  'uzbekistan': 'UZ',
  'venezuela': 'VE',
  'vietnam': 'VN',
  'viet nam': 'VN',
  'yemen': 'YE',
  'zambia': 'ZM',
  'zimbabwe': 'ZW',
};

/// Subdivision abbreviations for countries whose states and provinces have
/// well-known short forms, keyed by country code.
const Map<String, Map<String, String>> _subdivisions =
    <String, Map<String, String>>{
      'US': _usStates,
      'CA': _canadianProvinces,
      'AU': _australianStates,
    };

const Map<String, String> _usStates = <String, String>{
  'alabama': 'AL',
  'alaska': 'AK',
  'arizona': 'AZ',
  'arkansas': 'AR',
  'california': 'CA',
  'colorado': 'CO',
  'connecticut': 'CT',
  'delaware': 'DE',
  'florida': 'FL',
  'georgia': 'GA',
  'hawaii': 'HI',
  'idaho': 'ID',
  'illinois': 'IL',
  'indiana': 'IN',
  'iowa': 'IA',
  'kansas': 'KS',
  'kentucky': 'KY',
  'louisiana': 'LA',
  'maine': 'ME',
  'maryland': 'MD',
  'massachusetts': 'MA',
  'michigan': 'MI',
  'minnesota': 'MN',
  'mississippi': 'MS',
  'missouri': 'MO',
  'montana': 'MT',
  'nebraska': 'NE',
  'nevada': 'NV',
  'new hampshire': 'NH',
  'new jersey': 'NJ',
  'new mexico': 'NM',
  'new york': 'NY',
  'north carolina': 'NC',
  'north dakota': 'ND',
  'ohio': 'OH',
  'oklahoma': 'OK',
  'oregon': 'OR',
  'pennsylvania': 'PA',
  'rhode island': 'RI',
  'south carolina': 'SC',
  'south dakota': 'SD',
  'tennessee': 'TN',
  'texas': 'TX',
  'utah': 'UT',
  'vermont': 'VT',
  'virginia': 'VA',
  'washington': 'WA',
  'west virginia': 'WV',
  'wisconsin': 'WI',
  'wyoming': 'WY',
  'district of columbia': 'DC',
};

const Map<String, String> _canadianProvinces = <String, String>{
  'alberta': 'AB',
  'british columbia': 'BC',
  'manitoba': 'MB',
  'new brunswick': 'NB',
  'newfoundland and labrador': 'NL',
  'northwest territories': 'NT',
  'nova scotia': 'NS',
  'nunavut': 'NU',
  'ontario': 'ON',
  'prince edward island': 'PE',
  'quebec': 'QC',
  'saskatchewan': 'SK',
  'yukon': 'YT',
};

const Map<String, String> _australianStates = <String, String>{
  'new south wales': 'NSW',
  'victoria': 'VIC',
  'queensland': 'QLD',
  'western australia': 'WA',
  'south australia': 'SA',
  'tasmania': 'TAS',
  'australian capital territory': 'ACT',
  'northern territory': 'NT',
};
