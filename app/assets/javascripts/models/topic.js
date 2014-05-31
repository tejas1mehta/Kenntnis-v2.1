Quora.Models.Topic = Backbone.Model.extend({
  urlRoot: "api/topics",
  parse: function (response) {
    var topic = this;
    // debugger
    console.log(response.questions)
    if(response.questions){
      topic._questions = [];
      _(response.questions).each(function(question){
        var newQuestion = new Quora.Models.Question(question, {parse: true});
        topic._questions.push(newQuestion)
      })

      delete response.questions;
    }

    if(response.author){
      this._author =  new Quora.Models.User(response.author);

      delete response.author;
    }

    if (response.followers_join){
      response.followers_join.forEach(function(follower_join){
        var newFollower = new Quora.Models.Following(follower_join)

        var followerExists = Quora.followings.models.filter(function(model) {return model.id === newFollower.id});
        if (followerExists.length === 0){
          Quora.followings.add(newFollower)
        }
      })
    }
    return response
  }
});
