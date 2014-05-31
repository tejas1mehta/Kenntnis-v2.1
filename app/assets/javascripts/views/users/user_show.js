Quora.Views.UserShow = Backbone.CompositeView.extend({
  template: JST["users/show"],
  tagName: "div style='overflow:scroll;'",

  initialize: function () {
    this.listenTo(this.model, "sync change", this.render);
    var userinfoView =
      new Quora.Views.UserAddInfo({ model: this.model });
    this.addSubview("#user_info", userinfoView);

    this.numScrolls = 0
    $(window).bind("scroll", this.$el, this.checkEndPage.bind(this))

  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.addMoreResults()
    }
  },

  addMoreResults: function(){

    this.numScrolls += 1;
    view = this

    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id,
      data: {
         num_scrolls: view.numScrolls
      },
      success: function(response){
        // var user = new Quora.Models.User({id: id});
        // debugger
        // user.set(response.attributes)

        view.model.parseProfile(response)
        view.model.profileView.forEach(function(profileViewObj){
          view.addSubview(("#recent-activity"), profileViewObj)
        })
      }
    })

  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      user : this.model
    });
    this.$el.html(renderedContent);
    if (this.model.profileView){
      this.model.profileView.forEach(function(profileViewObj){
        view.addSubview("#recent-activity", profileViewObj)
      })
    }
    // console.log(this.model.profileView)
    //this.attachSubviews();
    // debugger
    this.attachSubviews();
    return this
  },

  addQuestionCreated: function(QuestionCreated, selector){
    var questionMiniShow = new Quora.Views.QuestionMiniShow({
      model: QuestionCreated
    });
    this.addSubview(selector, questionMiniShow);
  },
  addAnswerCreated: function(AnswerCreated, selector){
    var answerFullShow = new Quora.Views.AnswerFullShow({
      model: AnswerCreated
    });
    this.addSubview(selector, answerFullShow);
  },


});
