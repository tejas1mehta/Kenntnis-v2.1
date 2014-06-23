Quora.NotfnViewMixIn = {
  findObjClass: function(checkObj){
    var objectClass;
    if (!checkObj){ checkObj = this.object }
    if (checkObj instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (checkObj instanceof Quora.Models.Topic){
      objectClass = "Topic";
    } else if (checkObj instanceof Quora.Models.User){
      objectClass = "User";
    } else if (checkObj instanceof Quora.Models.QuestionAnswer){
      objectClass = "Answer";
    }

    return objectClass
  },

  seeNotifications: function(){
    var notificationsArray = [];
    var allNotificationObjects = this.notifications.notificationObjects();
    var i = 0;
    while(i < allNotificationObjects.length){
      var nfnObject = allNotificationObjects[i];
      var notification = this.notifications.models[i];
      var n_kind = notification.get("notification_kind");
      var show_name = (notification.get("num_users") + " user(s)");
      var created_at = new Date(notification.get("created_at")).toLocaleString();
      var body_text
      var object_ref
      switch( this.findObjClass(nfnObject)){
        case("Answer"):
          body_text = " your answer: " + nfnObject.get("main_answer")
          object_ref = "<a href='#questions/" + nfnObject.get("question_id") + "'>"
          break;
        case("Question"):
          body_text = " your question: " + nfnObject.get("main_question")
          object_ref = "<a href='#questions/" + nfnObject.id + "'>"
          break;
        case("Topic"):
          body_text = " your title: " + nfnObject.get("title")
          object_ref = "<a href='#topics/" + nfnObject.id + "'>"          
          break;
        case("User"):
          body_text = " you"
          object_ref = "<a href='#users/" + nfnObject.id + "'>"                   
      }
      i += 1;
      notificationsArray.push({"show_name": show_name, "n_kind": n_kind,
      "body_text": body_text, "object_ref": object_ref, "created_at": created_at })      
    }

    return notificationsArray
  },
}