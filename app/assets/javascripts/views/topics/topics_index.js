Quora.Views.TopicsIndex = Backbone.View.extend({

  template: JST['topics/index'],
  tagName: "div class='col-lg-4 col-lg-offset-4' style='font-size:150%'",
  initialize: function () {
    this.listenTo(this.collection, "sync", this.render);
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      topics : this.collection
    });

    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  },

});
