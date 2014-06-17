Quora.Views.UserNew = Backbone.View.extend({
  template: JST["users/new"],
  events: {
    "submit form": "submit"
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

    var user = new Quora.Models.User(params["user"]);
    user.save({}, {
      success: function (resp) {
        // Add user ID?
        Quora.currentUser = new Quora.Models.User(resp.attributes)
        Quora.allUsers.add(Quora.currentUser, {merge:true})
        
        $('body').removeClass("back_image")   
        var navbarView = new Quora.Views.NavBar({
          model: Quora.currentUser
        });
        Quora.currentRouter.$navbar.html(navbarView.render().$el)
        Backbone.history.navigate("#users/settings", { trigger: true });
      }
    });
  }
});
