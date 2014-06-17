Quora.Collections.Followings = Backbone.Collection.extend({
  url: "api/followings",
  model: Quora.Models.Following,

  findAllFollowings: function(object_id, object_type){
    var allFollowings = this.filter(function(followObj){
       return (object_id === followObj.get("followable_id") &&
         object_type === followObj.get("followable_type"))
    })

    return new Quora.Collections.Followings(allFollowings)
  },

//for Users
  doesExist: function(user_id, followable_id, followable_type){
    var followingExists = this.filter(function(followObj){
       return (user_id === followObj.get("f_id") &&
         followable_id === followObj.get("followable_id") &&
         followable_type === followObj.get("followable_type"))
    })

    return (followingExists[0])  
  },
// Only call on allFollowings collection
  findFriendFollowings: function(){
    var collectionFollowings = this

    var friendModels = Quora.allUsers.filter(function(someUser){
      var isFollowing = collectionFollowings.filter(function(followObj){
        return (followObj.get("f_id") === someUser.id && (Quora.followings.doesExist(Quora.currentUser.id, someUser.id, "User")
                 || (someUser.id === Quora.currentUser.id)))
      }).length;

      return (isFollowing)
    });
    return friendModels
  },
});
_.extend(Quora.Collections.Followings.prototype, Quora.CollectionMixIn);