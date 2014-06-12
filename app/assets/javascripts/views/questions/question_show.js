Quora.Views.QuestionShow = Backbone.CompositeView.extend({
  template: JST["questions/show"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);

    this.listenTo(this.model.answers(), "add", this.addAnswer);
    this.model.answers().each(this.addAnswer.bind(this));
    
    this.qnAuthor = Quora.allUsers.getQuestionAuthor(this.model)
    this.qnAuthor.models[0] ? this.addAuthor(this.qnAuthor.models[0]) : this.listenTo(this.qnAuthor,"reset", this.addAuthor)

    this.topicsJoinsCollection = Quora.topicQuestionJoins.getTopicJoins(this.model);
    this.addTopics(this.topicsJoinsCollection)
    this.listenTo(this.topicsJoinsCollection,"reset", this.addTopics)

    var answerNewView = new Quora.Views.AnswerNew({ question: this.model });
    this.addSubview("#answer-new", answerNewView);

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)

    // var relUsersView = new Quora.Views.RelUserShow({model: this.model})
    // this.addSubview("#rel_users", relUsersView)
    console.log("In Question Show Initialize method" + Quora)

  },

  addAnswer: function (answer) {
    var answerShow = new Quora.Views.AnswerShow({ model: answer });
    this.addSubview("#answers", answerShow);
  },

  addAuthor: function(author){
    this.removeAllSubviews("#author")
    if (author.models[0]){
      var authorMiniShow = new Quora.Views.UserMiniShow({ model: author.models[0], justName: true });

      this.addSubview("#author", authorMiniShow);
    }
  },

  addTopics: function(topicJoinsPassed){
    var topicIDs = topicJoinsPassed.map(function(topicJoin){
      return (topicJoin.get("topic_id"))
    });

    var qnTopics = Quora.topics.getTopics(topicIDs)
    this.removeAllSubviews("#topics")
    var view = this;
    _(qnTopics).each(function(topic){
      var topicMiniShow = new Quora.Views.TopicMiniShow({model: topic});
      view.addSubview("#topics", topicMiniShow);  
      topicMiniShow.$el.addClass("add_same_line")
      topicMiniShow.$el.removeClass("show_bottom_border")   
    })

  },

  render: function () {
    // debugger
    var view = this;

    var renderedContent = this.template({
      question : this.model
    });

    this.$el.html(renderedContent);

    this.attachSubviews();

    return this;
  }
});
