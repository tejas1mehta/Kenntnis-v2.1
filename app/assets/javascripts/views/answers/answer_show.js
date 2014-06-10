Quora.Views.AnswerShow = Backbone.CompositeView.extend({
  template: JST["answers/show"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);

    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)
  },
  events: {
    "submit form#upvote" : "UpvoteAnswer"
  },

  // UpvoteAnswer: function(event){
  //   event.preventDefault()
  //
  //   upvoteObj = new Quora.Models.Upvote({upvoteable_id: this.model.id , upvoteable_type: "Answer"})
  //   var view = this
  //   upvoteObj.save({},{
  //     success: function(resp){
  //       view.model.attributes.upvotes += 1
  //       // Quora.currentUser.answersUpvoted.push(view.model)
  //       Quora.upvotes.add(upvoteObj)
  //       view.render()
  //     },
  //     error: function(resp){
  //       console.log("errorred")
  //     }
  //   })
  // },
  render: function () {
    var view = this;
    var renderedContent = this.template({
      answer : this.model
    });

    this.$el.html(renderedContent);
    this.attachSubviews();

    return this;
  }
});
