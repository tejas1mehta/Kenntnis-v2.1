Quora.Views.SessionNew = Backbone.View.extend({
  template: JST["sessions/new"],
  tagName: "div",
  events: {
    "submit form#login": "submit"
  },

  render: function () {
    var renderedContent = this.template({});
    this.$el.html(renderedContent);
    $('body').addClass("back_image")
    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();

    var params = $(event.currentTarget).serializeJSON();
    userSession = new Quora.Models.Session(params["session"]);
    userSession.save({}, {
      success: function (resp) {
        Quora.currentUser = new Quora.Models.User(resp.attributes)
        Quora.createSession()
        $('body').removeClass("back_image")

        Backbone.history.navigate("#users/"+ Quora.currentUser.id +"/feed", { trigger: true });
      }
    });
  }
});
