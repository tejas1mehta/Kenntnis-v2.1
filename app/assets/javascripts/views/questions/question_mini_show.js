Quora.Views.QuestionMiniShow = Backbone.CompositeView.extend({
  template: JST["questions/minishow"],
  tagName: "div class='show_bottom_border' id='mini-show'",
  initialize: function () {
    this.listenTo(this.model, "sync", this.render);

    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)
  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      question : this.model
    });

    this.$el.html(renderedContent);
    this.attachSubviews();

    return this;
  }
  // events: {
  //   "submit form#upvote" : "UpvoteQuestion",
  //   "submit form#follow" : "FollowQuestion",
  //   "submit form#unfollow" : "UnfollowQuestion",
  // },
  //
  // UpvoteQuestion: function(event){
  //   event.preventDefault()
  //
  //   upvoteObj = new Quora.Models.Upvote({upvoteable_id: this.model.id , upvoteable_type: "Question"})
  //   var view = this
  //   upvoteObj.save({},{
  //     success: function(resp){
  //       view.model.attributes.upvotes += 1
  //       Quora.votes.add(upvoteObj)
  //       view.render()
  //     },
  //     error: function(resp){
  //       console.log("errorred")
  //     }
  //   })
  // },
  //
  // FollowQuestion: function(event){
  //   event.preventDefault()
  //
  //   followObj = new Quora.Models.Following({followable_id: this.model.id , followable_type: "Question"})
  //   var view = this
  //   console.log(followObj)
  //   followObj.save({},{
  //     success: function(resp){
  //       // view.model.attributes.follows += 1 Add follows attribute
  //       Quora.followings.add(followObj)
  //       view.render()
  //     },
  //     error: function(resp){
  //       console.log("errorred")
  //     }
  //   })
  // },
  //
  // UnfollowQuestion: function(event){
  //   event.preventDefault()
  //   var followingID = $("follow_id").val();
  //   console.log(followingID)
  //   unfollowObj = new Quora.Models.Following({id: followingID});
  //   var view = this;
  //   unfollowObj.destroy({
  //     success: function(resp){
  //       // view.model.attributes.follows += 1 Add follows attribute
  //       Quora.followings.remove(unfollowObj)
  //       view.render()
  //     },
  //     error: function(resp){
  //       console.log("errorred")
  //     }
  //   })
  // },


});
