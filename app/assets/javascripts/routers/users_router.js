Quora.Routers.Users = Backbone.Router.extend({
  initialize: function(options) {
    this.$rootEl = options.$rootEl
    this.$navbar = options.$navbar
  },

  routes: {
    "": "NewSession",
    "users/new": "UserNew",
    "users/logout": "Logout",
    "users/settings": "Settings",
    "users/search": "Search",
    "users/:id": "UserProfile",
    "users/:id/feed": "UserFeed",
    "users/:id/addinfo": "UserAddInfo",
    "questions/new" : "QuestionNew",
    "questions/:id" : "QuestionShow",
    "question/:ques_id/answer/:ans_id" : "AnswerShow",
    "topics" : "TopicsIndex",
    "topics/new" : "TopicNew",
    "topics/:id" : "TopicShow",
  },

  Search: function(){
  },

  UserQuestionsCreated: function(id){

    $.ajax({
      type: "GET",
      url: "/api/users" + id + "/questions_created",
      success: function(response){
        console.log("logouted")
        Quora.currentUser = null
        Backbone.history.navigate("", { trigger: true });
      }
    })
  },

  Settings: function(){
    $(window).unbind("scroll")

    var newSettingsView = new Quora.Views.UserSettings({
      model: Quora.currentUser
    });
    this._swapView(newSettingsView);    
  },

  Logout: function(id){
    // console.log(Quora.userSession.url)
    // Quora.userSession.destroy()
    $(window).unbind("scroll")

    this.$navbar.empty()
    $.ajax({
      type: "DELETE",
      url: "/api/session",
      success: function(response){
        console.log("logouted")
        Quora.currentUser = null
        Backbone.history.navigate("", { trigger: true });
      }
    })
  },

  UserFeed: function(id){
    $(window).unbind("scroll")

    console.log("IN FEED")
    // Quora.numVisitsPages.feed = 1
    Quora.currentUser.fetch({data: {
         last_an_time: 0,
         last_qn_time: 0,
         num_scrolls: 0,
         data_to_fetch: "feed_results"
    }})

    var userFeedView = new Quora.Views.UserFeed({
      model: Quora.currentUser
    });

    this._swapView(userFeedView)
  },

  NewSession: function () {
    $(window).unbind("scroll")

    if (Quora.currentUser){
      Quora.currentRouter.navigate("#users/"+ Quora.currentUser.id +"/feed", { trigger: true });
    } else {
    var newSessionView = new Quora.Views.SessionNew();
    this._swapView(newSessionView);
    }
  },

  UserNew: function () {
    $(window).unbind("scroll")

    var newUserView = new Quora.Views.UserNew();
    this._swapView(newUserView);
  },

  UserProfile: function (id) {
    $(window).unbind("scroll")
    var that = this;
    var user = new Quora.Models.User({id: id});

    user.fetch({data: {
             last_obj_time: 0,
             data_to_fetch: "profile_results"
    }})

    userProfileView = new Quora.Views.UserShow({
          model: user
    });
    userProfileView.lastDataFetched = "profile_results";
    this._swapView(userProfileView);
  },

  UserAddInfo: function (id) {
    $(window).unbind("scroll")

    var user = new Quora.Models.User({id: id});
    user.fetch()

    var newUserView = new Quora.Views.UserAddInfo({
      model: Quora.currentUser
    });
    this._swapView(newUserView);
  },
  TopicsIndex: function(){
    $(window).unbind("scroll")

    var alltopics = new Quora.Collections.Topics();

    alltopics.fetch()

    var topicsView = new Quora.Views.TopicsIndex({
      collection: alltopics
    });

    this._swapView(topicsView)
  },

  TopicNew: function(){
    $(window).unbind("scroll")

    var newTopicModel = new Quora.Models.Topic();
    var newTopicView = new Quora.Views.TopicNew({
      model: newTopicModel
    });
    this._swapView(newTopicView);
  },

  TopicShow: function(id) {
    $(window).unbind("scroll")

    var TopicModel = new Quora.Models.Topic({id: id});
    TopicModel.fetch()
    // debugger
    console.log(TopicModel.questions)
    var TopicShowView = new Quora.Views.TopicShow({
      model: TopicModel
    });

    this._swapView(TopicShowView);
  },

  QuestionNew: function() {
    $(window).unbind("scroll")

    var newQuestionModel = new Quora.Models.Question();
    var newQuestionView = new Quora.Views.QuestionNew({
      model: newQuestionModel
    });
    this._swapView(newQuestionView);
  },

  QuestionShow: function(id) {
    $(window).unbind("scroll")

    var questionModel = new Quora.Models.Question({id: id});
    questionModel.fetch()

    var QuesShowView = new Quora.Views.QuestionShow({
      model: questionModel
    });

    this._swapView(QuesShowView);
  },
  _swapView: function (newView) {
    if (this.currentView) {
      this.currentView.remove();

    }

    this.$rootEl.html(newView.render().$el);

    this.currentView = newView;
  }

});
