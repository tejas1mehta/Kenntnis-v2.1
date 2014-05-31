object.attributes.each do |key, value|
  json.extract! object, key.to_sym
end