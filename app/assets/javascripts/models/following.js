Quora.Models.Following = Backbone.Model.extend({
  urlRoot: "api/followings",

  parse: function(response){
    if (response.followable){
      switch (response.followable_type){
        case("Topic"):
          var newTopic = new Quora.Models.Topic(response.followable)
          break;
        case("Question"):
          Quora.questions.add(response.followable,{merge:true})
          break;
        case("User"):
          Quora.allUsers.add(response.followable, {merge:true})
          break;
      }
    }
    return response
  }
});
