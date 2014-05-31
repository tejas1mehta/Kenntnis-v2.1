Quora.Models.Question = Backbone.Model.extend({
  urlRoot: "api/questions",
  answers: function(){
    this._answers = this._answers ||
      new Quora.Collections.QuestionAnswers([], { question: this });
    return this._answers;
  },

  // author: function(){
  //   this._author = this._author ||
  //   new Quora.Models.User();
  //
  //   return this._author;
  // },

  parse: function (response) {
    var question = this;
    if (response.answers) {
      this.answers().set(response.answers, { parse: true });
      delete response.answers;
    }
    if(!response.author){
      debugger
    }
    if(response.author){
      this._author =  new Quora.Models.User(response.author, {parse: true});
      delete response.author;
    }

    if (response.followers_join){
      response.followers_join.forEach(function(follower_join){
        var newFollower = new Quora.Models.Following(follower_join, {parse: true})

        var followerExists = Quora.followings.models.filter(function(model) {return model.id === newFollower.id});
        if (followerExists.length === 0){
          Quora.followings.add(newFollower)
        }
      })
    }

    if(response.topics){
      question._topics = [];
      _(response.topics).each(function(topic){
        var newTopic = new Quora.Models.Topic(topic, {parse: true});
        question._topics.push(newTopic)
      })

      delete response.topics;
    }

    if(response.upvotes_join){
      response.upvotes_join.forEach(function(upvote_join){
        var newUpvote = new Quora.Models.Upvote(upvote_join)

        var upvoteExists = Quora.upvotes.models.filter(function(model) {return model.id === newUpvote.id});
        if (upvoteExists.length === 0){
          Quora.upvotes.add(newUpvote)
        }
      })
    }

    if(response.relevant_user_joins){
      response.relevant_user_joins.forEach(function(rel_user_join){
        // debugger
        var newRelUserJoin = new Quora.Models.QnRelevantUser(rel_user_join,{parse: true})

        var relUserJoinExists = Quora.relUserJoins.models.filter(function(model) {return model.id === newRelUserJoin.id});
        if (relUserJoinExists.length === 0){
          Quora.relUserJoins.add(newRelUserJoin)
        }
      })
    }

    return response;
  }
});
