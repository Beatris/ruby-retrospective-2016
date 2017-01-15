UNITS_MAPPING = {
  'F' => {
    'F' => ->(x) { x },
    'C' => ->(x) { (x - 32) * 5.0 / 9.0 },
    'K' => ->(x) { (x - 32) * 5.0 / 9.0 + 273.15 },
  },
  'C' => {
    'F' => ->(x) { x * 9.0 / 5.0 + 32 },
    'C' => ->(x) { x },
    'K' => ->(x) { x + 273.15 },
  },
  'K' => {
    'F' => ->(x) { (x - 273.15) * 9 / 5 + 32 },
    'C' => ->(x) { x - 273.15 },
    'K' => ->(x) { x },
  },
}

def convert_between_temperature_units(degrees, from, to)
  UNITS_MAPPING[from][to].call(degrees)
end

DEFAULT_UNIT = 'C'
SUBSTANCE_TEMPERATURES = {
  'water' => {melting_temp: 0, boiling_temp: 100},
  'ethanol' => {melting_temp: -114, boiling_temp: 78.37},
  'gold' => {melting_temp: 1064, boiling_temp: 2700},
  'silver' => {melting_temp: 961.8, boiling_temp: 2162},
  'copper' => {melting_temp: 1085, boiling_temp: 2567},
}

def melting_point_of_substance(substance, unit)
  convert_between_temperature_units(
    SUBSTANCE_TEMPERATURES[substance][:melting_temp],
    DEFAULT_UNIT,
    unit
  )
end

def boiling_point_of_substance(substance, unit)
  convert_between_temperature_units(
    SUBSTANCE_TEMPERATURES[substance][:boiling_temp],
    DEFAULT_UNIT,
    unit
  )
end
