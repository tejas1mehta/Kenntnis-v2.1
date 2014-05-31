json.sent_messages @sent_messages, :sent_to, :message_body, :subject, :parent_message_id

json.received_messages @received_messages, :sent_by, :message_body, :subject, :parent_message_id