Quora.Views.AnswerShow = Backbone.CompositeView.extend({
  template: JST["answers/show"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)
  },
  events: {
    "submit form#upvote" : "UpvoteAnswer"
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      answer : this.model
    });

    this.$el.html(renderedContent);
    this.attachSubviews();

    return this;
  }
});
