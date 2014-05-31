require 'addressable/uri'
require 'rest-client'
require 'json'
require 'nokogiri'

question = "What is the name of the current US president?"

split_question = question.split(/[\s?]/)
p split_question
question_type_keywords = ["When", "Why", "Describe", "Define", "Who", "Whom",
"What", "Which", "How"]
proper_nouns = []

# noun_groups# Get from WordNet
# Right now conduct the qiki search with proper nouns + question focus
# get 1-2 pages, could add adjectives later ?
question_focus = ""
split_question.each_with_index do |ques_word, ind|
  if noun_groups.include?(ques_word) && question_focus == ""
    question_focus = ques_word
  end
  if question_type_keywords.include?(ques_word)
    question_type_keyword = ques_word
    question_type_index = ind
  elsif ques_word.capitalize == ques_word
    proper_nouns.push(ques_word)
  end
end

case question_type_keyword
when "when"
  answer_type = "time"
when "why"
  answer_type = "reason"
when "where"
  answer_type = "place"
when "describe"
  answer_type = "description"
when "define"
  answer_type = "definition"
when "who"
  answer_type = "person"
when "whom"
  answer_type = "person"
when "what" || "which" || "name" # Separate these out
  if question_focus == ""
    answer_type = "name"
  else
    
    answer_type = "person"
    # ques_hyponyms # get hyponyms of question_focus
    # if ques_hyponyms.include?("person")
    #   answer_type = "person"
    # else
    #   answer_type = question_focus
  end 
when "how"
  ques_how_desc = split_question[question_type_index + 1]
  #Use wordnet here?
end

# # p answer_type, question_type_keyword

wiki_search_keywords = proper_nouns.join(" ") + " " + question_focus
wiki_url = Addressable::URI.new(
  :scheme => "http",
  :host => "en.wikipedia.org",
  :path => "w/api.php",
  :query_values => {:format => "json", action: "query", list: "search",
   srsearch: wiki_search_keywords}
).to_s

json_pages = JSON.parse(RestClient.get(wiki_url))

searched_titles = parsed_wiki_titles["query"]["search"]

first_title_result = searched_titles[0]["title"]

wiki_url = Addressable::URI.new(
  :scheme => "http",
  :host => "en.wikipedia.org",
  :path => "w/api.php",
  :query_values => {:format => "json", action: "query",
   titles: first_title_result, prop: "revisions", rvprop: "content"}
).to_s

look_in_page = JSON.parse(RestClient.get(wiki_url))
page_content = look_in_page["parse"]["text"]["*"]
# page_id = look_in_page["query"]["pages"].keys.first
# page_content = look_in_page["query"]["pages"][page_id]["revisions"].first["*"]
page_text = Nokogiri::HTML(page_content).text
page_text_array = page_text.split(/[\n?\.]/)

# hyponyms_answer_type # get from wordnet
candidate_answers = []
page_text_array.each do |sentence|
  num_hyponym_matches = 0
  num_ques_matches = 0
  split_sentence = sentence.split(" ")
  split_sentence.each do |word|
    num_hyponym_matches += 1 if hyponyms_answer_type.include?(word)
    num_ques_matches += 1 if split_question.include?(word)
    num_proper_noun_matches += 1 if wiki_search_keywords.include?(word)
  end

  if num_hyponym_matches > 0
    total_sent_score = num_hyponym_matches + num_ques_matches + num_proper_noun_matches
    candidate_answers.push({sentence => total_sent_score})
  end
end

candidate_answers.sort{|cand_ans1, cand_ans2| cand_ans2.values.first <=> cand_ans1.values.first}

p candidate_answers[0]
