Quora.Views.QuestionNew = Backbone.CompositeView.extend({
  template: JST["questions/new"],
  events: {
    "submit form#submit_question": "submit",
    "click button#extra_topic" : "addTopic"
  },

  initialize: function(){
    this.allTopics = new Quora.Collections.Topics()
    this.allTopics.fetch()
    var addTopicView = new Quora.Views.AddTopic({collection: this.allTopics})
    this.addSubview("#addTopics", addTopicView)
  },

  addTopic: function(event){
    event.preventDefault()
    console.log("IN ADDT OPIC")
    debugger

    var addTopicView = new Quora.Views.AddTopic({collection: this.allTopics})
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
    console.log("IN QUESTION SUBMIT")
    var params = $(event.currentTarget).serializeJSON();

    var question = new Quora.Models.Question(params["question"]);
    debugger
    question.save({}, {
      success: function (resp) {
        // Add user ID?
        console.log("In resp" + resp)
        Backbone.history.navigate("#questions/" + resp.id, { trigger: true });
        //Add to users collection?
      }
    });
  }
});
