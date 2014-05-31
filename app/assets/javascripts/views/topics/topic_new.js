Quora.Views.TopicNew = Backbone.View.extend({
  template: JST["topics/new"],
  events: {
    "submit form": "submit"
  },

  render: function () {
    var renderedContent = this.template({
      topic: this.model
    });
    this.$el.html(renderedContent);

    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();

    var params = $(event.currentTarget).serializeJSON();
    // var question = new Quora.Models.Question(params);
    this.model.save(params["topic"], {
      success: function (resp) {
        //add to question's answer collection 
        
      }
    });
  }
});
