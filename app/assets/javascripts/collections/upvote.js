Quora.Collections.Upvotes = Backbone.Collection.extend({
  url: "api/upvotes",
  model: Quora.Models.Upvote,

  findAllVotes: function(object_id, object_type){
    var allUpvotes = this.filter(function(upvoteObj){
       return (object_id === upvoteObj.get("upvoteable_id") &&
         object_type === upvoteObj.get("upvoteable_type"))
    })

    return new Quora.Collections.Upvotes(allUpvotes)
  },

  // Only call on allVotes collection
  findFriendVotes: function(){
    var collectionUpvotes = this
    // debugger
    var friendModels = Quora.allUsers.filter(function(someUser){
      var hasUpvoted = collectionUpvotes.filter(function(upvoteObj){
        return (upvoteObj.get("user_id") === someUser.id  && (Quora.followings.doesExist(Quora.currentUser.id, someUser.id, "User")
          || (someUser.id === Quora.currentUser.id)))
      }).length;

      return (hasUpvoted)
    });

    return friendModels
  },

  doesUpvoteExist: function(user_id, upvoteable_id, upvoteable_type){
    var upvoteExists = this.filter(function(followObj){
       return (user_id === followObj.get("user_id") &&
         upvoteable_id === followObj.get("upvoteable_id") &&
         upvoteable_type === followObj.get("upvoteable_type"))
    })

    return (upvoteExists[0])  
  },

});
_.extend(Quora.Collections.Upvotes.prototype, Quora.CollectionMixIn);