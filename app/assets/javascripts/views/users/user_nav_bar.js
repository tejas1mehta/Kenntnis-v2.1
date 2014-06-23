Quora.Views.NavBar = Backbone.CompositeView.extend({
  template: JST["users/navbar"],
  events: {
    "submit form": "submit"
  },
  initialize: function(){
    this.listenTo(Quora.currentUser,"sync change", this.render);
    this.notificationView = new Quora.Views.NewNotifications();
    this.addSubview("#add_notif_btn", this.notificationView)
  },

  returnNotifications: function(){
    return view.notificationView.newNotifContent
  },

  render: function () {
    var renderedContent = this.template({
      user: Quora.currentUser
    });
    this.$el.html(renderedContent);
    this.attachSubviews();
    // this.notificationView.newNotifContent ="ab"
    var view= this;
    // $('#notif_btn').popover({trigger: "hover",html:true})
    // $('#notif_btn').popover({trigger: "hover", content: ""})
    return this;
  },

  attachSubviews: function () {
    var view = this;
    _(this.subviews()).each(function (subviews, selector) {
      _(subviews).each(function (subview) {
        view.attachSubview(selector, subview, true);
      });
    });
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();

    var params = $(event.currentTarget).serializeJSON();
    // var user = new Quora.Models.User(params["user"]);
    $.ajax({
      type: "GET",
      url: "/api/users/search",
      data:{
        keywords: params["keywords"]
      },
      success: function(response){
        Quora.currentUser.parseSearch(response)
        var userSearchResults = new Quora.Views.UserSearchResults({
          model: Quora.currentUser
        });
        
        Quora.currentRouter._swapView(userSearchResults)
      }
    })

    Quora.currentRouter.navigate("#users/search")
  },


});
