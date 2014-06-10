json.results @results do |result|
  result.attributes.each do |key, value|
    json.extract! result, key.to_sym
  end
  json.resultclass result.class.to_s
  if (result.class == Question || result.class == Topic)
    json.author result.author
  end

end