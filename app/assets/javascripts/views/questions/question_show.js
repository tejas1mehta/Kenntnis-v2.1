Quora.Views.QuestionShow = Backbone.CompositeView.extend({
  template: JST["questions/show"],
 
  initialize: function (options) {
    this.listenTo(this.model, "sync", this.render);
    if (this.incAns = options.includeAnswers){
      this.listenTo(this.model.answers(), "add", this.addAnswer);
      this.model.answers().each(this.addAnswer.bind(this));
      
      this.filCols = [];
      this.filCols.topicsJoinsCollection = Quora.topicQuestionJoins.getTopicJoins(this.model);
      this.filCols.topicsJoinsCollection.each(this.addTopic.bind(this))
      this.listenTo(this.filCols.topicsJoinsCollection,"add", this.addTopic)

      var answerNewView = new Quora.Views.AnswerNew({ question: this.model });
      this.addSubview("#answer-new", answerNewView);
      // this.$el.removeClass("qns-des")
    }
    this.model.attributes.author_id ? this.addAuthor() : this.listenToOnce(this.model, "sync", this.addAuthor)

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".qn-upvote-btn", upvoteView)
    this.open = false
    // var relUsersView = new Quora.Views.RelUserShow({model: this.model})
    // this.addSubview("#rel_users", relUsersView)
  },

  events:{
    "click #qn-edit" : "editObj",
    "submit #qn-update" : "endEditing"
  },

  addAnswer: function (answer) {
    var answerShow = new Quora.Views.AnswerShow({ model: answer });
    this.addSubview("#answers", answerShow);
  },

  addAuthor: function(){
      var author = Quora.allUsers.getOrAdd(this.model.get("author_id"));
      var authorMiniShow = new Quora.Views.UserMiniShow({ model: author, justName: true });

      this.addSubview("#qn-author", authorMiniShow);
  },

  addTopic: function(topicJoin){
    var topic = Quora.topics.get(topicJoin.get("topic_id"));
    var topicMiniShow = new Quora.Views.TopicMiniShow({model: topic});
    this.addSubview("#topics", topicMiniShow);  
    topicMiniShow.$el.addClass("add_same_line")
    topicMiniShow.$el.removeClass("show_bottom_border")  
  },

  render: function () {
    // debugger
    var view = this;

    var renderedContent = this.template({
      question : this.model,
      incAns : this.incAns,
      isEditing : this.open
    });

    this.$el.html(renderedContent);

    this.attachSubviews();

    return this;
  }
});
_.extend(Quora.Views.QuestionShow.prototype, Quora.ViewMixIn);