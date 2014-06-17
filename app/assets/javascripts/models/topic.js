Quora.Models.Topic = Backbone.Model.extend({
  urlRoot: "api/topics",
  parse: function (response) {
    var topic = this;
    if(response.questions_join){
      Quora.topicQuestionJoins.add(response.questions_join,{merge:true, parse:true})
      delete response.questions;
    }

    if(response.author){
      Quora.allUsers.add(response.author)
      delete response.author;
    }

    if (response.followers_join){
      Quora.followings.add(response.followers_join)
      delete response.followers_join
    }
    return response
  }
});
