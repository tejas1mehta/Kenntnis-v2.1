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

  findFriendFollowings: function(){
    var collectionFollowings = this
    var friendModels = Quora.userFollowers.filter(function(userFollower){
      var isFollowing = collectionFollowings.filter(function(followObj){
        return (followObj.get("f_id") === userFollower.id)
      }).length;

      return (isFollowing)
    });
    return friendModels
  },
});
_.extend(Quora.Collections.Followings.prototype, Quora.CollectionMixIn);