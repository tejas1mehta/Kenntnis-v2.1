// Change the questions to a collection , not ust an array if ability to make a new quewtion on show page is needed
Quora.Views.TopicShow = Backbone.CompositeView.extend({
  template: JST["topics/show"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)
  },

  addAuthor: function(author){
    var renderedAuthor = "<a href='#users/" + author.get("id") +"'>" + author.get("name") + "</a>";

    $("#author").append(renderedAuthor)
  },

  addQuestion: function(question){
    var renderedQuestion = "<a href='#questions/" + question.get("id") + "'>" + question.get("main_question") + "</a><br>";

    $("#questions").append(renderedQuestion)
  },


  render: function () {
    var view = this;
    var renderedContent = this.template({
      topic : this.model
    });

    if(view.model._questions){
      view.model._questions.forEach(function(question){
        var questionShow =
          new Quora.Views.QuestionMiniShow({ model: question });
          view.addSubview("#questions", questionShow);
      })
    }

    this.$el.html(renderedContent);

    console.log(view.model._followers)
    if (view.model._author){
      view.addAuthor(view.model._author)
    }

    this.attachSubviews();

    return this;
  }
});
