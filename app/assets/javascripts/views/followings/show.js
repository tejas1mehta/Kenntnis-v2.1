Quora.Views.FollowingShow = Backbone.View.extend({
  template: JST["followings/show"],

  initialize: function (options) {
    this.object = options.object
    this.listenTo(this.object, "sync change objFollowed objUnFollowed", this.getFollowers)
    this.getFollowers()
  },

  events: {
    "submit form#follow" : "followObject",
    "submit form#unfollow" : "unfollowObject"
  },
  
  getFollowers: function(){
    this.objFollowing = Quora.followings.doesExist(Quora.currentUser.id, this.object.id, this.findObjClass())
    this.FollowersObject = Quora.followings.findAllFollowings(this.object.id, this.findObjClass())
    this.FriendFollowersObj = this.FollowersObject.findFriendFollowings();
    this.numNonFriendFollowers = this.FollowersObject.length - this.FriendFollowersObj.length;
    this.render()
  },

  followObject: function(event){
    event.preventDefault()
    followObj = new Quora.Models.Following({followable_id: this.object.id , followable_type: this.findObjClass()})
    var view = this
    followObj.save({},{
      success: function(resp){
        Quora.followings.add(followObj)
        view.object.trigger("objFollowed")
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  unfollowObject: function(event){
    event.preventDefault()
    var followingID = this.$("#follow_id").val();
    unfollowObj = new Quora.Models.Following({id: parseInt(followingID)});
    var view = this;
    unfollowObj.destroy({
      success: function(resp){
        Quora.followings.remove(unfollowObj)
        view.object.trigger("objUnFollowed")
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      objFollowingtemplate : this.objFollowing,
      numExFollowers : this.numNonFriendFollowers,
      friendFollowers : this.FriendFollowersObj,
      onObjectID: this.object.id
    });

    this.$el.html(renderedContent);

    return this;
  }
});

_.extend(Quora.Views.FollowingShow.prototype, Quora.ViewMixIn);