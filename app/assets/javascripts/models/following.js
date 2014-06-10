Quora.Models.Following = Backbone.Model.extend({
  urlRoot: "api/followings",

  parse: function(response){
    if (response.followable){
      switch (response.followable_type){
        case("Topic"):
          var newTopic = new Quora.Models.Topic(response.followable)

          // var topicExists = Quora.topics.filter(function(model) {return model.id === newTopic.id});
          // if (topicExists.length === 0){
          //   Quora.topics.add(newTopic)
          // }
          break;
        case("Question"):
          var newQuestion = new Quora.Models.Question(response.followable)

          var questionExists = Quora.questions.filter(function(model) {return model.id === newQuestion.id});
          if (questionExists.length === 0){
            Quora.questions.add(newQuestion)
          }
          break;
        case("User"):
          var newUser = new Quora.Models.User(response.followable)
          // userFollowers here means users that are followed by the current user
          if (response.f_id == Quora.currentUser.id){
            var userExists = Quora.userFollowers.filter(function(model) {return model.id === newUser.id});
            if (userExists.length === 0){
              Quora.userFollowers.add(newUser)
            }
          }
          break;
      }
    }
    return response
  }
});
