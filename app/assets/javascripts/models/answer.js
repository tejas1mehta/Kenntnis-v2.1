Quora.Models.QuestionAnswer = Backbone.Model.extend({
  urlRoot: "api/answers/",
  parse: function (response) {
    var question = this;
    if (response.question) {
      newQuestion = new Quora.Models.Question(response.question, { parse: true });
      var questionExists = Quora.questions.filter(function(model) {return model.id === newQuestion.id});
      if (questionExists.length === 0){
        Quora.questions.add(newQuestion)
      } else {
        var questionIndex = Quora.questions.indexOf(questionExists)
        Quora.questions[questionIndex] = newQuestion
      }
      this._question = newQuestion
      delete response.question;
    }

    if(response.author){

      this._author =  new Quora.Models.User(response.author);

      delete response.author;
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
    return response
  },
});
