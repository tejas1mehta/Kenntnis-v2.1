json.partial! 'api/shared/extract_all', object: @answer

json.author @answer.author
json.question @answer.question
json.comments @answer.comments, :comment_body, :author, :upvotes, :parent_comment_id