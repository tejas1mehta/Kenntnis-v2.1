Quora.Views.UpvoteShow = Backbone.View.extend({
  template: JST["upvotes/show"],

  initialize: function (options) {
    this.object = options.object
    this.listenTo(this.object, "sync change", this.render)
    this.listenTo(Quora.upvotes, "add", this.render)
  },

  events: {
    "submit form#upvote" : "upvoteObject"
  },

  upvoteObject: function(event){
    console.log("IN METHOD")
    event.preventDefault()
    var objectClass;

    if (this.object instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (this.object instanceof Quora.Models.QuestionAnswer){
      objectClass = "Answer";
    }

    upvoteObj = new Quora.Models.Upvote({upvoteable_id: this.object.id , upvoteable_type: objectClass})
    var view = this
    debugger
    upvoteObj.save({},{
      success: function(resp){
        Quora.upvotes.add(upvoteObj)
        view.render()
      },
      error: function(resp){
        console.log("errorred")
      }
    })
  },

  render: function () {
    var view = this;

    var objectClass;

    if (this.object instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (this.object instanceof Quora.Models.QuestionAnswer){
      objectClass = "Answer";
    }

    var objVoting = Quora.upvotes.filter(function (upvote) {return (upvote.get("upvoteable_id") === view.object.id &&
     Quora.currentUser.id === upvote.get("user_id") && upvote.get("upvoteable_type") === objectClass )})[0]

    var UpvotesObject = Quora.upvotes.findAllVotes(this.object.id, objectClass)

    var FriendUpvotesObj = UpvotesObject.findFriendVotes();

    var numNonFriendUpvoters = UpvotesObject.length - FriendUpvotesObj.length;

    var renderedContent = this.template({
      hasVoted : objVoting,
      numExVoters: numNonFriendUpvoters,
      friendUpvoters : FriendUpvotesObj
    });
    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  }
});
