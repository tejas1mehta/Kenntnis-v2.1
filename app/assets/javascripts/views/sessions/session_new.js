Quora.Views.SessionNew = Backbone.View.extend({
  template: JST["sessions/new"],
  tagName: "div",
  events: {
    "submit form#login": "submit"
  },

  render: function () {
    var renderedContent = this.template({});
    this.$el.html(renderedContent);

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

        // var navbarView = new Quora.Views.NavBar({
        //   model: Quora.currentUser
        // });
        // console.log("About to render")
        // Quora.currentRouter.$navbar.html(navbarView.render().$el)
        Backbone.history.navigate("#users/"+ Quora.currentUser.id +"/feed", { trigger: true });
      }
    });
  }
});
