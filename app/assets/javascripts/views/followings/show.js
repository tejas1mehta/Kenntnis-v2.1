// Number of upvotes and followings should also go here?

Quora.Views.FollowingShow = Backbone.View.extend({
  template: JST["followings/show"],

  initialize: function (options) {
    this.object = options.object
    this.listenTo(this.object, "sync change", this.render)
    this.listenTo(Quora.followings, "add sync remove change", this.render)
  },

  events: {
    "submit form#follow" : "followObject",
    "submit form#unfollow" : "unfollowObject"
  },

  followObject: function(event){
    console.log("IN MSg")
    event.preventDefault()
    var objectClass;

    if (this.object instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (this.object instanceof Quora.Models.Topic){
      objectClass = "Topic";
    } else if (this.object instanceof Quora.Models.User){
      objectClass = "User";
    }

    followObj = new Quora.Models.Following({followable_id: this.object.id , followable_type: objectClass})

    var view = this
    console.log(followObj)
    followObj.save({},{
      success: function(resp){
        // view.model.attributes.follows += 1 Add follows attribute
        Quora.followings.add(followObj)
        view.render()
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  unfollowObject: function(event){
    event.preventDefault()
    var followingID = this.$("#follow_id").val();
    console.log(followingID)
    unfollowObj = new Quora.Models.Following({id: parseInt(followingID)});
    var view = this;
    unfollowObj.destroy({
      success: function(resp){
        // view.model.attributes.follows += 1 Add follows attribute
        Quora.followings.remove(unfollowObj)
        view.render()
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  render: function () {
    var view = this;

    var objectClass

    if (this.object instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (this.object instanceof Quora.Models.Topic){
      objectClass = "Topic";
    } else if (this.object instanceof Quora.Models.User){
      objectClass = "User";

    }

    var objFollowing = Quora.followings.filter(function (following) {return (following.get("followable_id") === view.object.id &&
     Quora.currentUser.id === following.get("f_id") && following.get("followable_type") === objectClass )})[0]

    var FollowersObject = Quora.followings.findAllFollowings(this.object.id, objectClass)

    var FriendFollowersObj = FollowersObject.findFriendFollowings();

    var numNonFriendFollowers = FollowersObject.length - FriendFollowersObj.length;

    var renderedContent = this.template({
      objFollowingtemplate : objFollowing,
      numExFollowers : numNonFriendFollowers,
      friendFollowers : FriendFollowersObj,
      onObjectID: this.object.id
    });

    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  }
});
