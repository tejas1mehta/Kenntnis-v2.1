Quora.Views.UserAddInfo = Backbone.View.extend({
  template: JST["users/addinfo"],
  events: {
        "submit form": "submit"
  },
  initialize: function(){
     this.listenTo(this.model, "sync", this.render);
  },

  render: function () {
    console.log(this.model)
    var renderedContent = this.template({
      user: this.model
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
        view.render()
      }
    })
  },
});
