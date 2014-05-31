Quora.Views.QuestionShow = Backbone.CompositeView.extend({
  template: JST["questions/show"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);
    this.listenTo(
      this.model.answers(), "add", this.addAnswer
    );

    var answerNewView =
      new Quora.Views.AnswerNew({ question: this.model });
    this.addSubview("#answer-new", answerNewView);

    this.model.answers().each(this.addAnswer.bind(this));

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)

    var relUsersView = new Quora.Views.RelUserShow({model: this.model})
    this.addSubview("#rel_users", relUsersView)

  },

  addAnswer: function (answer) {
    var answerShow =
      new Quora.Views.AnswerShow({ model: answer });
    this.addSubview("#answers", answerShow);
  },

  addAuthor: function(author){
    var renderedAuthor = "<a href='#users/" + author.get("id") +"'>" + author.get("name") + "</a>";

    $("#author").html(renderedAuthor)
  },

  addFollower: function(follower){
    var renderedFollower = "<a href='#users/" + follower.get("id") +"'>" + follower.get("name") + "</a> <br>";

    $("#followers").append(renderedFollower)
  },

  addTopic: function(topic){
    var renderedTopic = "<a href='#topics/" + topic.get("id") + "'>" + topic.get("title") + "</a><br>";

    $("#topics").append(renderedTopic)
  },


  render: function () {

    var view = this;

    var renderedContent = this.template({
      question : this.model
    });

    this.$el.html(renderedContent);

    if (view.model._author){
      view.addAuthor(view.model._author)
    }
    if(view.model._followers){
      view.model._followers.forEach(function(follower){
        view.addFollower(follower)
      })
    }
    if(view.model._topics){
      view.model._topics.forEach(function(topic){
        view.addTopic(topic)
      })
    }



    this.attachSubviews();

    return this;
  }
});
