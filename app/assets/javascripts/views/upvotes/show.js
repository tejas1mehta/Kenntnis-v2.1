Quora.Views.UpvoteShow = Backbone.View.extend({
  template: JST["upvotes/show"],

  initialize: function (options) {
    this.object = options.object
    this.listenTo(this.object, "sync change objUpvoted", this.getUpvoters)
    // this.listenTo(Quora.upvotes, "add", this.getUpvoters)
    this.getUpvoters()
  },

  events: {
    "submit form#upvote" : "upvoteObject"
  },

  getUpvoters: function(){
    this.objVoting = Quora.upvotes.doesUpvoteExist(Quora.currentUser.id, this.object.id, this.findObjClass())
    this.UpvotesObject = Quora.upvotes.findAllVotes(this.object.id, this.findObjClass())
    this.FriendUpvotesObj = this.UpvotesObject.findFriendVotes();
    this.numNonFriendUpvoters = this.UpvotesObject.length - this.FriendUpvotesObj.length;
    this.render()
  },

  upvoteObject: function(event){
    event.preventDefault()

    upvoteObj = new Quora.Models.Upvote({upvoteable_id: this.object.id , upvoteable_type: this.findObjClass()})
    var view = this

    upvoteObj.save({},{
      success: function(resp){
        Quora.upvotes.add(upvoteObj)
        view.object.trigger("objUpvoted")
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      hasVoted : this.objVoting,
      numExVoters: this.numNonFriendUpvoters,
      friendUpvoters : this.FriendUpvotesObj
    });
    this.$el.html(renderedContent);

    return this;
  }
});

_.extend(Quora.Views.UpvoteShow.prototype, Quora.ViewMixIn);