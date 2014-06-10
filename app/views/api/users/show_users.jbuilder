json.results @results do |result|
	json.partial! 'api/shared/extract_all', object: result
	json.user_followers_join result.user_followers_join
	json.resultclass result.class.to_s
end

json.last_obj_time @results.last.sorted_time_str if (@results.length > 0)
