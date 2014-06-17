Quora.Models.TopicQuestionJoin = Backbone.Model.extend({
  parse: function(response){
    if (response.topic){
      Quora.topics.add(response.topic,{merge:true, parse:true})
      delete response.topic
    }

    if (response.question){
      Quora.questions.add(response.question,{merge:true, parse:true})
      delete response.question
    }
    return response
  }
});
