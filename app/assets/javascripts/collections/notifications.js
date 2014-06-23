Quora.Collections.Notifications = Backbone.Collection.extend({
  url: "api/notifications",
  model: Quora.Models.Notification,

  newNotifications: function(){
    var newNotificationsCriteria = function(){
      return (this.get("viewed") === false)
    };
    return this.findFilteredObjects(newNotificationsCriteria)
  },

  notificationObjects: function(){
    var notifyObjects = []
    this.forEach(function(notifyObj){
       var colName = notifyObj.get("about_object_type").toLowerCase() + "s"
       notifyObjects.push( Quora[colName].get(parseInt(notifyObj.get("about_object_id"))) )
    })

    return notifyObjects
  }

});
_.extend(Quora.Collections.Notifications.prototype, Quora.CollectionMixIn);