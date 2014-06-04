Quora.Views.UserFeed = Backbone.CompositeView.extend({
  template: JST["users/feed"],
  tagName: "div id='user_feed'",
  initialize: function () {
    var view = this;
    // this.listenTo(this.model, "sync", this.render);
    this.numScrolls = 0
    // this.$el.on("submit", $("#follow"), this.followedUser.bind(this))
    // $(window).scroll(function() {
    //    if($(window).scrollTop() + $(window).height() == $(document).height()) {
    //        view.addMoreResults()
    //    }
    // });
    // debugger
    console.log(this.$el)
    $(window).bind("scroll", $("#user_feed"), this.checkEndPage.bind(this))
    // this.$el.bind("scroll", this.checkEndPage.bind(this))

    // this.$el.scroll(function() {
    //   console.log("SCROLLING")
    //    if($(window).scrollTop() + $(window).height() == $(document).height()) {
    //        view.addMoreResults()
    //    }
    // });
  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.addMoreResults()
    }
  },

  followedUser: function(event){
    debugger
    var follower_id = parseInt($(event.target).find("#followable_id").val());
    console.log("In user show event" + follower_id)
    var userFollowedView = this.model.recUserViews.filter(function(recUserView){
      return (recUserView.model.id === follower_id)
    });

    this.removeSubview("#rec_users", userFollowedView[0])
  },

  addMoreResults: function(){
    console.log("LastQnTime" + this.lastFeedQnTime + "LastAnTime" + this.lastFeedAnTime);
    console.log($("#user_feed"))
    this.numScrolls += 1;
    view = this
    $.ajax({
      type: "GET",
      url: "/api/users/" + Quora.currentUser.id + "/feed",
      data: {
         last_an_time: view.lastFeedAnTime,
         last_qn_time: view.lastFeedQnTime,
         num_scrolls: view.numScrolls         
      },
      success: function(response){
        // var user = new Quora.Models.User({id: id});
        Quora.currentUser.parseFeed(response)
        // var userFeedView = new Quora.Views.UserFeed({
        //   model: Quora.currentUser
        // });
        view.lastFeedAnTime = response.last_an_time
        view.lastFeedQnTime = response.last_qn_time
        console.log("DATA RECEIVED")
        debugger
        view.model.feedView.forEach(function(feedViewObj){
          view.addSubview(("#feed-activity"), feedViewObj)
        })

        $("#rec_users").html("")
        view.model.recUserViews.forEach(function(recUserView){
          view.addSubview("#rec_users", recUserView)
        })
      }
    })
  },

  render: function () {
    var view = this;
    console.log(this.$el)
    var renderedContent = this.template({
      user : this.model
    });

    this.$el.html(renderedContent);
    console.log("LASTQNTIME" + this.lastFeedQnTime)
    if (this.model.feedView){
      this.model.feedView.forEach(function(feedViewObj){
        view.addSubview(("#feed-activity"), feedViewObj)
      })
    }

    if (this.model.recUserViews){
      this.$("#rec_users").on("submit", $("#follow"), this.followedUser.bind(this))
      this.model.recUserViews.forEach(function(recUserView){
        view.addSubview("#rec_users", recUserView)
      })
    }
    //this.attachSubviews();
    // this.attachSubviews();
    return this;
  },


});
