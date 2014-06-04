Quora.Views.AnswerFullShow = Backbone.CompositeView.extend({
  template: JST["answers/fullshow"],

  initialize: function () {
    // this.listenTo(this.model, "sync", this.render);

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)


  },

  render: function () {
    var view = this;
    // var d = new Date();
    // var n = d.toLocaleString();
    var renderedContent = this.template({
      answer : this.model
    });
    if(this.model._question){
      var questionView = new Quora.Views.QuestionMiniShow({model: this.model._question})
      this.addSubview("#question", questionView)
      debugger
    }

    this.$el.html(renderedContent);
    this.attachSubviews();
    questionView.$el.removeClass("show_bottom_border")

    return this;
  }
});
