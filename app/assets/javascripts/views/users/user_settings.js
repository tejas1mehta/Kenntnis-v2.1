Quora.Views.UserSettings = Backbone.View.extend({
  template: JST["users/settings"],
  events: {
        "submit form": "submit"
  },
  initialize: function(){
     this.listenTo(this.model, "sync", this.render);
  },

  render: function () {
    console.log(this.model)
    var renderedContent = this.template({
      curUser: this.model
    });
    this.$el.html(renderedContent);

    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();
    var params = $(event.currentTarget).serializeJSON();

    this.model.save(params["user"], {
      success: function (resp) {
        Backbone.history.navigate("#users/" + view.model.id, { trigger: true });
      }
    })
  },
});
