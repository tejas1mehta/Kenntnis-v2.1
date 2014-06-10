Quora.Views.NavBar = Backbone.View.extend({
  template: JST["users/navbar"],
  events: {
    "submit form": "submit"
  },
  initialize: function(){
    this.listenTo(Quora.currentUser,"sync change", this.render)
  },

  render: function () {
    console.log("user_navbar" + this.model)
    console.log(Quora.currentUser)
    var renderedContent = this.template({
      user: Quora.currentUser
    });
    this.$el.html(renderedContent);
    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();

    var params = $(event.currentTarget).serializeJSON();
    console.log(Quora)
    // var user = new Quora.Models.User(params["user"]);
    $.ajax({
      type: "GET",
      url: "/api/users/search",
      data:{
        keywords: params["keywords"]
      },
      success: function(response){
        Quora.currentUser.parseSearch(response)
        var userSearchResults = new Quora.Views.UserSearchResults({
          model: Quora.currentUser
        });
        
        Quora.currentRouter._swapView(userSearchResults)
      }
    })

    Quora.currentRouter.navigate("#users/search")
  },
});
