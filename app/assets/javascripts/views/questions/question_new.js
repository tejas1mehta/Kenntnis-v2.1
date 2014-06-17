Quora.Views.QuestionNew = Backbone.CompositeView.extend({
  template: JST["questions/new"],
  events: {
    "submit form#submit_question": "submit",
    "click button#extra_topic" : "addTopic"
  },

  initialize: function(){
    Quora.topics.fetch()

    var addTopicView = new Quora.Views.AddTopic({collection: Quora.topics})
    this.addSubview("#addTopics", addTopicView)
  },

  addTopic: function(event){
    event.preventDefault()
    var addTopicView = new Quora.Views.AddTopic({collection: Quora.topics})
    this.addSubview("#addTopics", addTopicView)
  },

  render: function () {
    var renderedContent = this.template({
      question: this.model
    });
    this.$el.html(renderedContent);
    this.attachSubviews();
    return this;
  },

  submit: function (event) {
    var view = this;
    event.preventDefault();
    var params = $(event.currentTarget).serializeJSON();

    this.model.save(params["question"], {
      success: function (resp) {
        Quora.questions.add(this.model)
        Backbone.history.navigate("#questions/" + resp.id, { trigger: true });
      }
    });
  }
});
