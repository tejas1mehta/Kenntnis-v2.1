Quora.Models.Notification = Backbone.Model.extend({

  parse: function(response){
        switch(response.about_object.resultclass){
          case("Answer"):
            var question = Quora.questions.getOrAdd(response.about_object.question_id)
            question.answers().add(response.about_object, {merge: true, parse: true})
            Quora.answers.add(question.answers().get(response.about_object.id))
            break;
          case("Question"):
            Quora.questions.add(response.about_object,{merge: true, parse: true})
            break;
          case("Topic"):
            Quora.topics.add(response.about_object,{merge: true, parse: true})       
        }
        Quora.allUsers.add(response.sent_by,{merge: true, parse: true})
        delete response.about_object
        delete response.sent_by
        delete response.id
        this.set(response)
        this.id = response.backbone_id
        delete response.backbone_id
        
      },
});
