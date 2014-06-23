Quora.Views.NotificationsIndex = Backbone.View.extend({

  template: JST['notifications/index'],

  initialize: function(){
    this.notifications = Quora.notifications
  },

  render: function(){
    var notificationsDisplay = this.seeNotifications()
    var renderedNotfnContent = JST['notifications/index']({notifications: notificationsDisplay});
    this.$el.html(renderedNotfnContent)
    return this
  },

});
_.extend(Quora.Views.NotificationsIndex.prototype, Quora.NotfnViewMixIn);