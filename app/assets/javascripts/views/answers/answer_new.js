Quora.Views.AnswerNew = Backbone.View.extend({
  template: JST["answers/new"],
  events: {
    "submit form": "submit"
  },
  initialize: function(options){
    this.question = options.question;
  },

  render: function () {
    var renderedContent = this.template({
      question: this.question
    });
    this.$el.html(renderedContent);

    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();
    var params = $(event.currentTarget).serializeJSON();

    var answer = new Quora.Models.QuestionAnswer(params["answer"])
    answer._question = this.question
    answer._author = Quora.currentUser
    answer.save({}, {
      success: function (resp) {
        view.question.answers().add(answer);
        view.render();
      }
    });
  }
});
