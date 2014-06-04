Quora.Views.UserShow = Backbone.CompositeView.extend({
  template: JST["users/show"],
  tagName: "div",

  initialize: function () {
    // this.listenTo(this.model, "sync change", this.render);
    var userinfoView =
      new Quora.Views.UserAddInfo({ model: this.model });
    this.addSubview("#user_info", userinfoView);

    this.followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".user_following_btn", this.followingView)
    
    this.numScrolls = 0
    $(window).bind("scroll", this.$el, this.checkEndPage.bind(this))

  },
//WILL NOT WORK WITH MORE THAN 1 TABS - view.lastFunctionCalled
  events: {
    "click a#questions_created": "showQuestionsCreated",
    "click a#answers_created": "showAnswersCreated",
    "click a#followers": "showFollowers",
    "click a#followings": "showFollowings",
    "submit .user_following_btn form": "reRenderFollowingView" 
  },

  reRenderFollowingView: function(event){
    console.log("IN USERS SHOW FOLLOWING")
    event.preventDefault();
    this.removeSubview(".user_following_btn", this.followingView)
    this.addSubview(".user_following_btn", this.followingView)
  },

  showQuestionsCreated: function(event){
    if (event) {event.preventDefault()} 
    view = this
    console.log("IN QN CREATED:" + view.lastQnCreatedTime)
    if (view.lastFunctionCalled !== view.showQuestionsCreated){view.lastQnCreatedTime = 0}
    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id + "/questions_created",
      data: {
        last_obj_time: view.lastQnCreatedTime
      },
      success: function(response){
        view.model.parseObjects(response)
        if(view.lastFunctionCalled !== view.showQuestionsCreated){
          view.$el.find(".active").removeClass("active")
          view.$el.find("#questions_created").parent().addClass("active")
          view.$el.find("#recent-activity").empty() // Try to unbind events of subviews 
        }
        view.lastQnCreatedTime = response.last_obj_time
        view.model.objectsView.forEach(function(viewObj){
          view.addSubview(("#recent-activity"), viewObj)
        })
        // view.$el.find()
        console.log("IN QN CREATED SUCCESS:" + view.lastQnCreatedTime)
        view.lastFunctionCalled = view.showQuestionsCreated 
      }
    })
    Quora.currentRouter.navigate("#users/"+view.model.id+"/questions_created")
  },

  showAnswersCreated: function(event){
    if (event) {event.preventDefault()} 
    view = this
    console.log("IN AN CREATED:" + view.lastAnCreatedTime)
    view.lastAnCreatedTime = view.lastAnCreatedTime || 0
    if (view.lastFunctionCalled !== view.showAnswersCreated){view.lastAnCreatedTime = 0}
    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id + "/answers_created",
      data: {
        last_obj_time: view.lastAnCreatedTime
      },
      success: function(response){
        view.model.parseObjects(response)
        if(view.lastFunctionCalled !== view.showAnswersCreated){
          view.$el.find(".active").removeClass("active")
          view.$el.find("#answers_created").parent().addClass("active")
          view.$el.find("#recent-activity").empty() // Try to unbind events of subviews 
        }
        view.lastAnCreatedTime = response.last_obj_time
        view.model.objectsView.forEach(function(viewObj){
          view.addSubview(("#recent-activity"), viewObj)
        })
        // view.$el.find()
        console.log("IN AN CREATED SUCCESS:" + view.lastAnCreatedTime)
        view.lastFunctionCalled = view.showAnswersCreated 
      }
    })
    Quora.currentRouter.navigate("#users/"+view.model.id+"/answers_created")
  },


  showFollowers: function(event){
    if (event) {event.preventDefault()} 
    view = this
    console.log("IN Followers :" + view.lastFollowerTime)
    view.lastFollowerTime = view.lastFollowerTime || 0
    if (view.lastFunctionCalled !== view.showFollowers){view.lastFollowerTime = 0}
    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id + "/followers",
      data: {
        last_obj_time: view.lastFollowerTime
      },
      success: function(response){
        view.model.parseUserObjects(response)
        if(view.lastFunctionCalled !== view.showFollowers){
          view.$el.find(".active").removeClass("active")
          view.$el.find("#followers").parent().addClass("active")
          view.$el.find("#recent-activity").empty() // Try to unbind events of subviews 
        }
        view.lastFollowerTime = response.last_obj_time
        view.model.userObjectsView.forEach(function(viewObj){
          view.addSubview(("#recent-activity"), viewObj)
        })
        // view.$el.find()
        console.log("IN FOLLWOERS CREATED SUCCESS:" + view.lastFollowerTime)
        view.lastFunctionCalled = view.showFollowers 
      }
    })
    Quora.currentRouter.navigate("#users/"+view.model.id+"/followers")
  },


  showFollowings: function(event){
    if (event) {event.preventDefault()} 
    view = this
    console.log("IN Followings :" + view.lastFollowingTime)
    view.lastFollowingTime = view.lastFollowingTime || 0
    if (view.lastFunctionCalled !== view.showFollowings){view.lastFollowingTime = 0}
    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id + "/followings",
      data: {
        last_obj_time: view.lastFollowingTime
      },
      success: function(response){
        view.model.parseUserObjects(response)
        if(view.lastFunctionCalled !== view.showFollowings){
          view.$el.find(".active").removeClass("active")
         view.$el.find("#followings").parent().addClass("active")
          view.$el.find("#recent-activity").empty() // Try to unbind events of subviews 
        }
        view.lastFollowingTime = response.last_obj_time
        view.model.userObjectsView.forEach(function(viewObj){
          view.addSubview(("#recent-activity"), viewObj)
        })
        // view.$el.find()
        console.log("IN FOLLWINGS CREATED SUCCESS:" + view.lastFollowingTime)
        view.lastFunctionCalled = view.showFollowings 
      }
    })
    Quora.currentRouter.navigate("#users/"+view.model.id+"/followings")
  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.lastFunctionCalled()
    }
  },

  addMoreResults: function(){

    this.numScrolls += 1;
    view = this

    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id,
      data: {
         last_obj_time: view.lastObjTime
      },
      success: function(response){
        // var user = new Quora.Models.User({id: id});
        // debugger
        // user.set(response.attributes)
        if(view.lastFunctionCalled !== view.addMoreResults){
          view.$el.find("#recent-activity").empty() // Try to unbind events of subviews 
        }
        view.model.parseProfile(response)
        view.lastObjTime = response.last_obj_time
        view.model.profileView.forEach(function(profileViewObj){
          view.addSubview(("#recent-activity"), profileViewObj)
        })
        view.lastFunctionCalled = view.addMoreResults 
      }
    })

  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      user : this.model
    });
    this.$el.html(renderedContent);
    if (this.model.profileView){
      this.model.profileView.forEach(function(profileViewObj){
        view.addSubview("#recent-activity", profileViewObj)
      })
      view.lastFunctionCalled = view.addMoreResults 

    }
    // console.log(this.model.profileView)
    //this.attachSubviews();
    // debugger
    this.attachSubviews();
    return this
  },

  addQuestionCreated: function(QuestionCreated, selector){
    var questionMiniShow = new Quora.Views.QuestionMiniShow({
      model: QuestionCreated
    });
    this.addSubview(selector, questionMiniShow);
  },
  addAnswerCreated: function(AnswerCreated, selector){
    var answerFullShow = new Quora.Views.AnswerFullShow({
      model: AnswerCreated
    });
    this.addSubview(selector, answerFullShow);
  },


});
