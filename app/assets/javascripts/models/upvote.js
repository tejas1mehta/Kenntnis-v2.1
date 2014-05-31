Quora.Models.Upvote = Backbone.Model.extend({
  urlRoot: "api/upvotes",
  // parse: function(response){
  //
  //   if (reponse.followable){
  //     switch (response.followable_type){
  //       case("Topic"):
  //         var newTopic = new Quora.models.Topic(response.followable)
  //
  //         var topicExists = Quora.topics.filter(function(model) {return model.id === newTopic.id});
  //         if (topicExists.length === 0){
  //           Quora.topics.add(newTopic)
  //         }
  //         break;
  //       case("Question"):
  //         var newQuestion = new Quora.models.Question(response.followable)
  //
  //         var questionExists = Quora.questions.filter(function(model) {return model.id === newQuestion.id});
  //         if (questionExists.length === 0){
  //           Quora.questions.add(newQuestion)
  //         }
  //         break;
  //     }
  //   }
  //   return response
  // }
});
