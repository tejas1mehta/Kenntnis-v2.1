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
    this.last_obj_time  = 0
    this.numScrolls = 0
    $(window).bind("scroll", this.$el, this.checkEndPage.bind(this))
    this.lastDataFetched = "profile_results";
    this.addObjects()
  },

  addObjects: function(){
    var view = this;
    var objsView = this.model.objectsView
    view.$el.find("#loading_el").addClass("inv_el")

    objsView.forEach(function(objView){
      view.addSubview("#recent-activity", objView)
    })
    if(objsView.length > 0){
      this.last_obj_time = view.model.lastObjTime
    } else {
      this.last_obj_time = -1
    }
    
  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      user : this.model
    });
    this.$el.html(renderedContent);
    this.attachSubviews();
    return this
  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.moreResults()
    }
  },

  moreResults: function(){
    view = this
    if (view.last_obj_time !== -1){
      view.$el.find("#loading_el").removeClass("inv_el")
      view.model.fetch({data: {
               last_obj_time: view.last_obj_time,
               data_to_fetch: view.lastDataFetched
        },
        success: function(){
          view.addObjects()
        }
      })
    }
  },

  events: {
    "click a.profile_btn": "clickedButton",
    "submit .user_following_btn form": "reRenderFollowingView" 
  },

  clickedButton: function(event){
    event.preventDefault();
    // debugger
    var view = this;
    view.lastDataFetched = event.currentTarget.id;
    view.last_obj_time = 0;
    view.$el.find(".active").removeClass("active")
    view.$el.find("#" + view.lastDataFetched).parent().addClass("active")
    view.$el.find("#recent-activity").empty() // Try to unbind events of subviews
    Quora.currentRouter.navigate("#users/"+ view.model.id+ "/custom" )
    view.moreResults()
  },

  // reRenderFollowingView: function(event){
  //   console.log("IN USERS SHOW FOLLOWING")
  //   event.preventDefault();
  //   this.removeSubview(".user_following_btn", this.followingView)
  //   this.addSubview(".user_following_btn", this.followingView)
  // },
});
