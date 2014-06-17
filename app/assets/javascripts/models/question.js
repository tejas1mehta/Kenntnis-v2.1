Quora.Models.Question = Backbone.Model.extend({
  urlRoot: "api/questions",
  answers: function(){
    this._answers = this._answers ||
      new Quora.Collections.QuestionAnswers([], { question: this });
    return this._answers;
  },

  author: function(){
    if (this.attributes.author_id && !this._author){
      this._author = Quora.allUsers.get("author_id");
    }
    if (!this._author){
      this._author = new Quora.Models.User();
      Quora.allUsers.add(this._author)
    }

    return this._author
  },


  parse: function (response) {
    var question = this;
    if (response.answers) {
      this.answers().set(response.answers, { parse: true });
      delete response.answers;
    }

    if(response.author){
      // this.author().set(response.author)
      Quora.allUsers.add(response.author,{merge: true})
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

    return response;
  }
});
