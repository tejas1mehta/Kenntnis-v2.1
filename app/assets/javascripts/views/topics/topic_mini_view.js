Quora.Views.TopicMiniShow = Backbone.View.extend({
  template: JST["topics/minishow"],

  initialize: function () {
    this.listenTo(this.model, "sync", this.render);
  },

  render: function () {
    var view = this;
    // debugger
    var renderedContent = this.template({
      topic : this.model
    });

    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  }
});
