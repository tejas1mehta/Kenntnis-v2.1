Quora.Models.TopicQuestionJoin = Backbone.Model.extend({
  parse: function(response){
    if (response.topic){
      var newTopic = new Quora.Models.Topic(response.topic)
      var newTopicExists = Quora.topics.filter(function(model) {return model.id === newTopic.id});
      if (newTopicExists.length === 0){ Quora.topics.add(newTopic) }
    }

    return response
  }
});
