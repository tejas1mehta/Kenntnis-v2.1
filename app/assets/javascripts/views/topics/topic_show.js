// Change the questions to a collection , not ust an array if ability to make a new quewtion on show page is needed
Quora.Views.TopicShow = Backbone.CompositeView.extend({
  template: JST["topics/show"],

  initialize: function (options) {
    this.listenTo(this.model, "sync", this.render);
    if (this.addQns = options.addQuestions){
      this.filCols = [];
      this.filCols.topicsJoinsCollection = Quora.topicQuestionJoins.getQnJoins(this.model.id);
      this.filCols.topicsJoinsCollection.each(this.addQn.bind(this))
      this.listenTo(this.filCols.topicsJoinsCollection,"add", this.addQn)
    } 
    this.model.attributes.author_id ? this.addAuthor() : this.listenToOnce(this.model, "sync", this.addAuthor)
    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".topic-following-btn", followingView)

    this.open = false;
  },
  
  events:{
    "click #tc-edit" : "editObj",
    "submit #tc-update" : "endEditing"
  },

  addAuthor: function(){
      var author = Quora.allUsers.getOrAdd(this.model.get("author_id"));
      var authorMiniShow = new Quora.Views.UserMiniShow({ model: author, justName: true });

      this.addSubview("#tc-author", authorMiniShow);
  },

  addQn: function(newTopicJoin){
    var qn = Quora.questions.get(newTopicJoin.get("question_id"));
    var questionShow = new Quora.Views.QuestionShow({ model: qn });
    this.addSubview("#questions", questionShow); 
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      topic : this.model,
      addQns: this.addQns,
      isEditing : this.open
    });

    this.$el.html(renderedContent);

    this.attachSubviews();

    return this;
  }
});
_.extend(Quora.Views.TopicShow.prototype, Quora.ViewMixIn);