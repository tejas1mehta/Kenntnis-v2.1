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
    var friendModels = Quora.userFollowers.filter(function(userFollower){
      var hasUpvoted = collectionUpvotes.filter(function(upvoteObj){
        return (upvoteObj.get("user_id") === userFollower.id)
      }).length;

      return (hasUpvoted)
    });

    return friendModels
  },

});
