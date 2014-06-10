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
    // debugger
    // console.log(params)
    //
    // var questionKeywords = params["question"]["main_question"];
    // console.log(questionKeywords)
    //
    // var nlqasURL = "http://www.evi.com/q/how_tall_is_ben_affleck_in_feet_and_inches";
    // $.ajax({
    //   url: nlqasURL,
    //   type: "GET",
    //   success: function(response){
    //     console.log(response)
    //     debugger
    //   }
    // })

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
