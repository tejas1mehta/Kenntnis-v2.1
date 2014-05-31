Quora.Views.RelUserShow = Backbone.View.extend({
  template: JST["qn_relevant_users/show"],

  initialize: function (options) {
    this.listenTo(this.model, "sync change", this.render)
    // this.listenTo(Quora.upvotes, "add", this.render)
  },


  render: function () {
    var view = this;
    debugger
    var relUserIDs = [];
    Quora.relUserJoins.forEach(function (userJoin) {
     if (userJoin.get("question_id") == view.model.id){
      relUserIDs.push(userJoin.get("relevant_user_id"))
     }
    });

    var relUsers = Quora.relevantQnUsers.filter(function(relUser){ return (relUserIDs.indexOf(relUser.id) !== -1)});

    var renderedContent = this.template({
      relUsers : relUsers
    });
    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  },
  // events: {
  //   "submit form#upvote" : "upvoteObject"
  // },

  // upvoteObject: function(event){
  //   console.log("IN METHOD")
  //   event.preventDefault()
  //   var objectClass;
  //
  //   if (this.object instanceof Quora.Models.Question){
  //     objectClass = "Question";
  //   } else if (this.object instanceof Quora.Models.QuestionAnswer){
  //     objectClass = "Answer";
  //   }
  //
  //   upvoteObj = new Quora.Models.Upvote({upvoteable_id: this.object.id , upvoteable_type: objectClass})
  //   var view = this
  //   debugger
  //   upvoteObj.save({},{
  //     success: function(resp){
  //       // view.object.attributes.upvotes += 1
  //       // Instead of having an attribute fdor upvotes, upvote collection can have filteringmethod that returns all the upvote objects and its length , that way the users who have upvoted will also be visible.
  //       console.log("upvote saved")
  //       Quora.upvotes.add(upvoteObj)
  //       view.render()
  //     },
  //     error: function(resp){
  //       console.log("errorred")
  //     }
  //   })
  // },

});
