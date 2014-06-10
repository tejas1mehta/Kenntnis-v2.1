Quora.Views.UserShow = Backbone.CompositeView.extend({
  template: JST["users/show"],

  initialize: function () {
    // this.listenTo(this.model, "sync change", this.render);
    $(window).bind("scroll", this.$el, this.checkEndPage.bind(this))
  },

  checkEndPage: function(){
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
        this.addMoreResults()
    }
  },

  addMoreResults: function(){
    view = this

    $.ajax({
      type: "GET",
      url: "/api/users/" + view.model.id,
      data: {
         last_obj_time: view.lastObjTime
      },
      success: function(response){
        // var user = new Quora.Models.User({id: id});
        // debugger
        // user.set(response.attributes)

        view.model.parseProfile(response)
        view.lastObjTime = response.last_obj_time
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
    this.attachSubviews();
    return this
  },
});
