Quora.Views.UserFeed = Backbone.CompositeView.extend({
  template: JST["users/feed"],
  tagName: "div id='user_feed' style='overflow:scroll;'",
  initialize: function () {
    var view = this;
    this.listenTo(this.model, "sync", this.render);
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
    var follower_id = parseInt($(event.target).find("#followable_id").val());
    console.log("In user show event" + follower_id)
    var userFollowedView = this.model.recUserViews.filter(function(recUserView){
      return (recUserView.model.id === follower_id)
    });

    this.removeSubview("#rec_users", userFollowedView[0])
  },
  //
  // events: {
  //
  //   "scroll" : "addMoreResults"
  // },

  addMoreResults: function(){
    console.log("FIRED");
    console.log($("#user_feed"))
    this.numScrolls += 1;
    view = this
    $.ajax({
      type: "GET",
      url: "/api/users/" + Quora.currentUser.id + "/feed",
      data: {
         num_scrolls: this.numScrolls
      },
      success: function(response){
        // var user = new Quora.Models.User({id: id});
        Quora.currentUser.parseFeed(response)
        // var userFeedView = new Quora.Views.UserFeed({
        //   model: Quora.currentUser
        // });
        console.log("DATA RECEIVED")
        debugger
        view.model.feedView.forEach(function(feedViewObj){
          view.addSubview(("#feed-activity"), feedViewObj)
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

    if (this.model.feedView){
      // this.$el.scroll(function() {
      //   // if(view.$el.scrollTop() + view.$el.innerHeight() >= view.$el.scrollHeight) {
      //    if(view.$el.scrollTop()  + $(window).height() == $(document).height()){
      //       alert('end reached');
      //   }
      // })

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
