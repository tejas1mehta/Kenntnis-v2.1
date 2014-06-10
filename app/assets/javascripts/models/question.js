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
  
  //   return this._author;
  // },


  parse: function (response) {
    var question = this;
    if (response.answers) {
      this.answers().set(response.answers, { parse: true });
      delete response.answers;
    }

// Important to have the if statement here
    if(response.author){
      Quora.allUsers.add(response.author,{merge: true})
      // this._author = Quora.allUsers.get(response.author.id)
      // filter(function(someUser){
      //   return (someUser.id === response.author.id)
      // })[0]  
      delete response.author;
    }

    if (response.followers_join){
      Quora.followings.add(response.followers_join,{merge: true, parse: true})
      delete response.followers_join
    }

    if(response.topics_join){
      Quora.topicQuestionJoins.add(response.topics_join,{merge: true, parse: true})
      delete response.topics;
    }

    if(response.upvotes_join){
      Quora.upvotes.add(response.upvotes_join,{merge: true, parse: true})      
      delete response.upvotes_join;
    }
    // if(response.relevant_user_joins){
    //   response.relevant_user_joins.forEach(function(rel_user_join){
    //     // debugger
    //     var newRelUserJoin = new Quora.Models.QnRelevantUser(rel_user_join,{parse: true})

    //     var relUserJoinExists = Quora.relUserJoins.models.filter(function(model) {return model.id === newRelUserJoin.id});
    //     if (relUserJoinExists.length === 0){
    //       Quora.relUserJoins.add(newRelUserJoin)
    //     }
    //   })
    // }

    return response;
  }
});
