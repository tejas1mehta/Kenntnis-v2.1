Quora.Views.TopicMiniShow = Backbone.View.extend({
  template: JST["topics/minishow"],
  tagName: "div class='show_bottom_border'",
  initialize: function (options) {
    this.listenTo(this.model, "sync", this.render);
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      topic : this.model
    });

    this.$el.html(renderedContent);
    return this;
  }
});
