/* Resizer
   A helper object for changing font size.
*/
function RSResizer(target, increaser, decreaser, resetter) {
  this.target = target;
  this.increaser = increaser;
  this.decreaser = decreaser;
  this.resetter = resetter;
  this.original_size = parseInt($(this.target).css("font-size"));
  this.min_level = 1;
  this.max_level = 8;
  this.current_level = 1;
  var resizer = this;
  
  $(this.increaser).click(function(event) {
    resizer.up();
    return false;
  });
  
  $(this.decreaser).click(function(event) {
    resizer.down();
    return false;
  });
  
  $(this.resetter).click(function(event) {
    resizer.reset();
    return false;
  });
}

RSResizer.prototype.reset = function() {
  this.setLevel(1);
};

RSResizer.prototype.up = function() {
  if (this.current_level < this.max_level) {
    this.setLevel(this.current_level + 1);
  }
};

RSResizer.prototype.down = function() {
  if (this.current_level > this.min_level) {
    this.setLevel(this.current_level - 1);
  }
};

RSResizer.prototype.setLevel = function(level) {
  var modifier = (level - 1) + this.original_size;
  $(this.target).css("font-size", modifier + "px");
  this.current_level = level;
};
/* End Resizer */

/* Messenger */
function Messenger(options) {
  var messenger = this;
  this.container = options["container"];
  this.opener = options["opener"];
  this.resume_id = options["resume_id"];
  this.slug = options["slug"];
  this.opened = false;
  this.form = options["form"];
  this.closer = $(this.container + " .closer");
  
  $(this.opener).click(function(event) {
    if (messenger.opened) {
      messenger.closeMessageDialog();
    } else {
      messenger.openMessageDialog();
    }
    return false;
  });
  
  $(this.closer).click(function(event) {
    messenger.closeMessageDialog();
    return false;
  });
  
  $(this.form).submit(function(event){
    messenger.submitForm();
    return false;
  });
  
  $(this.form).ajaxStart(function(event){
    messenger.enableForm(false);
    messenger.showFormThrobber();
  });
  
  $(this.form).ajaxComplete(function(event){
    messenger.enableForm(true);
    messenger.hideFormThrobber();
  });
}

Messenger.prototype.showFormThrobber = function() {
  $(this.container + " #msgform_throbber").show();
};

Messenger.prototype.hideFormThrobber = function() {
  $(this.container + " #msgform_throbber").hide();
};

Messenger.prototype.enableForm = function(enabled) {
  $(this.form + " input, textarea").attr("disabled", !enabled);
};

Messenger.prototype.openMessageDialog = function() {
  $(this.container + " .message_dialog").slideDown();
  this.opened = true;
};

Messenger.prototype.closeMessageDialog = function() {
  $(this.container + " .message_dialog").slideUp();
  this.opened = false;
};

Messenger.prototype.clearErrorUI = function() {
  $(this.container + " .error_container").empty();
};

Messenger.prototype.submitForm = function() {
  this.clearErrorUI();
  var msg_data = $(this.form).serializeArray();
  var messenger = this;
  $.ajax({
    url: "/resumes/" + this.resume_id + "/messages",
    type: "POST",
    data: msg_data,
    dataType: "json",
    error: function(xhr, textStatus) {
      var error_ui = $(xhr.responseText);
      $(".error_container").append(error_ui);
    },
    success: function(data, textStatus) {
      window.alert("Message sent.");
      messenger.clearForm();
    },
  });
};

Messenger.prototype.clearForm = function() {
  $(this.form + " input:text, textarea").val("");
};
/* End Messenger */


/* MessageDestroyer */
function MessageDestroyer(options) {
  
}

MessageDestroyer.prototype.activate = function() {
  var destroyer = this;
  $(".delete_msg_btn").each(function(i, button){
    $(button).click(function(event){
      props = $(button).attr("rel").split(";");
      resume_id = props[0];
      msg_id = props[1];
      destroyer.destroy(resume_id, msg_id);
      return false;
    });
  });
};

MessageDestroyer.prototype.destroy = function(resume_id, msg_id) {
  var answer = confirm("Are you sure you want to delete this message?");
  if (answer) {
    $.ajax({
      url: "/resumes/" + resume_id + "/messages/" + msg_id,
      type: "POST",
      data: {
        _method: "DELETE"
      },
      error: function(xhr, textStatus) { window.alert("Delete message unexpected error"); },
      success: function(data, textStatus) {
        $("tr#msg_" + msg_id).slideUp();
      }
    });
  }
};
/* End MessageDestroyer */