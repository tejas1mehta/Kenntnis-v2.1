Quora.Views.NewNotifications = Backbone.View.extend({

  template: JST['notifications/new_notifications'],
  tagName: "li id='notif_btn' data-toggle='popover' data-placement='auto' ",
  initialize: function(){
    this.notifications = Quora.notifications.newNotifications();
    var view = this;
    // this.listenTo(this.newNotifications, "add remove change", this.seeNotifications);
    this.getNewNotifications()
    // setInterval(view.getNewNotifications, 600000)
    this.listenTo(this.notifications, "clear", this.changeDisplayNotifications);
  },

  events:{
    "click a#notifications-link": "preventDefault"
  },

  preventDefault: function(event){
    event.preventDefault()
  },

  getNewNotifications: function(){
    Quora.notifications.fetch({
      success:function(){
        Quora.navbarView.notificationView.changeDisplayNotifications()
      }
    })
  },

  changeDisplayNotifications: function(){
    var view = this 
    var notificationsDisplay = view.seeNotifications()
    var renderedNotfnContent = JST['notifications/notifications_text']({notifications: notificationsDisplay});
    view.$el.attr("data-content", renderedNotfnContent)
    view.render()
  },


  render: function(numNotifications){
    // var numNotifications = Quora.navbarView.notificationView.newNotifications.length;
    var renderedContent = this.template({numNotifications: this.notifications.length });
    this.$el.html(renderedContent)
    var add_title =  "<a href='#notifications'> All Notifications </a> &nbsp <a href='#notifications/clear'> Clear All Notifications </a>"
    this.$el.popover({trigger: "click",html:true, title: add_title})

    return this;
  },

});
_.extend(Quora.Views.NewNotifications.prototype, Quora.NotfnViewMixIn);