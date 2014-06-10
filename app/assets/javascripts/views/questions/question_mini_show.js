Quora.Views.QuestionMiniShow = Backbone.CompositeView.extend({
  template: JST["questions/minishow"],
  tagName: "div class='show_bottom_border' id='mini-show'",
  initialize: function () {
    this.listenTo(this.model, "sync", this.render);
    this.qnAuthor = Quora.allUsers.getQuestionAuthor(this.model)
    this.qnAuthor.models[0] ? this.addAuthor(this.qnAuthor.models[0]) : this.listenToOnce(this.qnAuthor,"reset", this.addAuthor)

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)
  },
  
  addAuthor: function(author){
    //this.removeAllSubviews("#author")
    var authorMiniShow = new Quora.Views.UserMiniShow({ model: author, justName: true });

    this.addSubview("#author", authorMiniShow);
  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      question : this.model
    });

    this.$el.html(renderedContent);
    this.attachSubviews();

    return this;
  }
});
