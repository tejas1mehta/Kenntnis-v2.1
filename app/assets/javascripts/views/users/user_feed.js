Quora.Views.UserFeed = Backbone.CompositeView.extend({
  template: JST["users/feed"],
  tagName: "div id='user_feed'",
  initialize: function () {
    var view = this;
    this.numScrolls = 0
    view.lastFeedAnTime = 0
    view.lastFeedQnTime = 0
    console.log(this.$el)
    $(window).bind("scroll", $("#user_feed"), this.checkEndPage.bind(this))
    this.listenToOnce(this.model,"objectsReceived", this.addObjects)
    // this.$("#rec_users").on("submit", $("#follow"), this.followedUser.bind(this))
  },

  events: {
    "submit #rec_users #follow": "followedUser" 
  },

  addObjects: function(){
    var view = this;
    var objsView = view.model.objectsView
    view.$el.find("#loading_el").addClass("inv_el")
    objsView.forEach(function(objView){
      view.addSubview("#feed-activity", objView)
    })
    view.$("#rec_users").html("")
    view.model.recUserViews.forEach(function(recUserView){
        view.addSubview("#rec_users", recUserView)
    })
    view.lastFeedAnTime = view.model.lastFeedAnTime;
    view.lastFeedQnTime = view.model.lastFeedQnTime;
  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.addMoreResults()
    }
  },

  addMoreResults: function(){
    console.log("LastQnTime in UserFeed moreResults View:" + this.lastFeedQnTime + "LastAnTime" + this.lastFeedAnTime);
    
    this.numScrolls += 1;
    view = this
    view.$el.find("#loading_el").removeClass("inv_el")
    Quora.currentUser.fetch({data: {
         last_an_time: view.lastFeedAnTime,
         last_qn_time: view.lastFeedQnTime,
         num_scrolls: view.numScrolls,
         data_to_fetch: "feed_results"
    }})
    this.listenToOnce(this.model,"objectsReceived", this.addObjects)
  },

  followedUser: function(event){
    var follower_id = parseInt($(event.target).find("#followable_id").val());
    console.log("In user show event" + follower_id)
    var userFollowedView = this.model.recUserViews.filter(function(recUserView){
      return (recUserView.model.id === follower_id)
    });

    this.removeSubview("#rec_users", userFollowedView[0])
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      user : this.model
    });

    this.$el.html(renderedContent);

    this.attachSubviews();
    return this;
  },


});
