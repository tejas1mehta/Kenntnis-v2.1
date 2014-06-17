Quora.Models.QuestionAnswer = Backbone.Model.extend({
  urlRoot: "api/answers/",
  parse: function (response) {
    var question = this;

    if (response.question) {
      Quora.questions.add(response.question,{merge: true, parse: true});
      this._question = Quora.questions.get(response.question.id);
      delete response.question;
    }
    
    if(response.author){
      Quora.allUsers.add(response.author, {merge: true});
      this._author =  Quora.allUsers.get(response.author.id);
      delete response.author;
    }

    if(response.upvotes_join){
      Quora.upvotes.add(response.upvotes_join, {merge:true});
      delete response.upvotes_join
    }


    return response
  },
});
