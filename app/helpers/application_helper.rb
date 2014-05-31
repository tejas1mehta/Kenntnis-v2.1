module ApplicationHelper
  def extract_all(result)
    debugger
    result.attributes.each do |key, value|
      json.extract! result, key.to_sym
    end
  end
end
