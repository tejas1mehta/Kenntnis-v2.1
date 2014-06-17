Quora.ViewMixIn = {
  findObjClass: function(){
    var objectClass;

    if (this.object instanceof Quora.Models.Question){
      objectClass = "Question";
    } else if (this.object instanceof Quora.Models.Topic){
      objectClass = "Topic";
    } else if (this.object instanceof Quora.Models.User){
      objectClass = "User";
    } else if (this.object instanceof Quora.Models.QuestionAnswer){
      objectClass = "Answer";
    }

    return objectClass
  },

  editObj: function(){
    event.preventDefault();
    this.open = true
    this.render()
  },

  endEditing: function(){
    event.preventDefault();
    this.open = false;

    var params = $(event.target).serializeJSON();
    var nameObj = Object.keys(params)[0]
    this.model.set(params[nameObj]);
    this.model.save();
    this.render();
  },
}

