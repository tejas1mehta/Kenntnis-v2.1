Quora.Views.AnswerShow = Backbone.CompositeView.extend({
  template: JST["answers/show"],

  initialize: function (options) {
    this.listenTo(this.model, "sync", this.render);
    this.listenTo(this.model, "destroy", this.remove);

    if (this.incQn = options.includeQuestion){
      var questionView = new Quora.Views.QuestionShow({model: this.model._question})
      this.addSubview("#question", questionView)
      questionView.$el.find(".qns-des").removeClass("qns-des")
    }
    var upvoteView = new Quora.Views.UpvoteShow({object: this.model})
    this.addSubview(".upvote-btn", upvoteView)
    this.open = false
  },
  events:{
    "click #ans-edit" : "editObj",
    "submit #ans-update" : "endEditing",
    "click #ans-delete" : "deleteAns"
  },

  deleteAns: function(){
    this.model.destroy()
  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      answer : this.model,
      incQn : this.incQn,
      isEditing : this.open
    });

    this.$el.html(renderedContent);
    this.attachSubviews();

    return this;
  }
});
_.extend(Quora.Views.AnswerShow.prototype, Quora.ViewMixIn);